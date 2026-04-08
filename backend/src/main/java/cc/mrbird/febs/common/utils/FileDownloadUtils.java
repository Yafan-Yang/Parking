package cc.mrbird.febs.common.utils;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;

import javax.servlet.http.HttpServletResponse;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * @author fank
 * @date 2021/6/9 17:00
 */
public class FileDownloadUtils {

    public static void downloadTemplate(HttpServletResponse response, String fileName) throws Exception {
        try (InputStream in = openTemplateStream(fileName);
            BufferedInputStream fis = new BufferedInputStream(in);
            BufferedOutputStream toClient = new BufferedOutputStream(response.getOutputStream())) {
            response.reset();
            response.setContentType("application/x-msdownload");
            response.setHeader("Content-Disposition", "attachment;filename=" + URLEncoder.encode(fileName, "UTF-8"));
            int len;
            while ((len = fis.read()) != -1) {
                toClient.write(len);
                toClient.flush();
            }
        } catch (IOException ex) {
            throw new Exception("下载文件失败！", ex);
        }
    }

    public static void downloadPdf(HttpServletResponse response, String fileName) throws Exception {
        Path pdfPath = FileUtil.resolvePath(fileName);
        try (InputStream in = Files.newInputStream(pdfPath);
             BufferedInputStream fis = new BufferedInputStream(in);
             BufferedOutputStream toClient = new BufferedOutputStream(response.getOutputStream())) {
            response.reset();
            response.setContentType("application/json");
//            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", "attachment;filename=" + URLEncoder.encode(pdfPath.getFileName().toString(), "UTF-8"));
            int len;
            while ((len = fis.read()) != -1) {
                toClient.write(len);
                toClient.flush();
            }
        } catch (IOException ex) {
            throw new Exception("下载文件失败！", ex);
        }
    }

    private static InputStream openTemplateStream(String fileName) throws IOException {
        if (fileName == null || fileName.trim().isEmpty()) {
            throw new FileNotFoundException("模板文件名不能为空");
        }

        Resource templateResource = new ClassPathResource("template/" + fileName);
        if (templateResource.exists()) {
            return templateResource.getInputStream();
        }

        Resource fallbackResource = new ClassPathResource("templates/" + fileName);
        if (fallbackResource.exists()) {
            return fallbackResource.getInputStream();
        }

        Path filePath = FileUtil.resolvePath(fileName);
        if (Files.isRegularFile(filePath)) {
            return Files.newInputStream(filePath);
        }

        throw new FileNotFoundException("模板文件不存在: " + fileName);
    }
}
