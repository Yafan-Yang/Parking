package cc.mrbird.febs.common.utils;

import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.regex.Pattern;

public class FileUtil {

    private static final Logger log = LoggerFactory.getLogger(FileUtil.class);
    private static final Pattern WINDOWS_ABSOLUTE_PATH = Pattern.compile("^[A-Za-z]:[/\\\\].*");

    /**
     *
     * @param file 文件
     * @param path   文件存放路径
     * @param fileName 原文件名
     * @return
     */
    public static String upload(MultipartFile file, String path, String fileName){
        String newFileName = FileNameUtils.getFileName(fileName);
        try {
            Path uploadDir = resolveDirectory(path);
            Files.createDirectories(uploadDir);
            Path dest = uploadDir.resolve(newFileName).normalize();
            //保存文件
            file.transferTo(dest.toFile());
            return newFileName;
        } catch (IOException | IllegalArgumentException e) {
            log.error("文件上传失败, path={}, fileName={}", path, fileName, e);
            return null;
        }
    }

    /**
     * 复制文件到指定目录
     * @param file
     * @param path
     * @param fileName
     * @return
     */
    public static String netUpload(MultipartFile file, String path, String fileName){
        String newFileName = fileName;
        try {
            Path uploadDir = resolveDirectory(path);
            Files.createDirectories(uploadDir);
            File dest = uploadDir.resolve(newFileName).normalize().toFile();
            //保存文件
//            file.transferTo(dest);
            FileUtils.copyInputStreamToFile(file.getInputStream(),dest);
            return newFileName;
        } catch (IOException | IllegalArgumentException e) {
            log.error("网络文件上传失败, path={}, fileName={}", path, fileName, e);
            return null;
        }
    }

    public static Path resolveDirectory(String path) {
        return resolvePath(path);
    }

    public static Path resolvePath(String path) {
        if (path == null || path.trim().isEmpty()) {
            throw new IllegalArgumentException("文件路径不能为空");
        }

        String normalizedPath = expandHome(path.trim());
        if (!isWindows() && WINDOWS_ABSOLUTE_PATH.matcher(normalizedPath).matches()) {
            throw new IllegalArgumentException("当前系统不是 Windows，不能使用 Windows 盘符路径: " + normalizedPath);
        }

        Path resolvedPath = Paths.get(normalizedPath).normalize();
        return resolvedPath.isAbsolute() ? resolvedPath : resolvedPath.toAbsolutePath().normalize();
    }

    private static boolean isWindows() {
        return System.getProperty("os.name", "")
                .toLowerCase(Locale.ROOT)
                .contains("win");
    }

    private static String expandHome(String path) {
        if ("~".equals(path)) {
            return System.getProperty("user.home");
        }
        if (path.startsWith("~/") || path.startsWith("~\\")) {
            return System.getProperty("user.home") + path.substring(1);
        }
        return path;
    }
}
