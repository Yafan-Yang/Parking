package cc.mrbird.febs.cos.controller;

import cc.mrbird.febs.common.utils.FileUtil;
import cc.mrbird.febs.common.utils.R;
import cc.mrbird.febs.cos.entity.UserInfo;
import cc.mrbird.febs.cos.service.FaceRecognition;
import cc.mrbird.febs.cos.service.IUserInfoService;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.entity.ContentType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import sun.misc.BASE64Encoder;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Locale;

/**
 * 人脸识别
 */
@RestController
@RequestMapping("/cos/face")
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class FaceRecognitionController {

    @Value("${febs.file.upload-dir:uploads}")
    private String uploadDir;

    private final FaceRecognition faceRecognition;

    private final IUserInfoService ownerInfoService;


    /**
     * 人脸注册
     *
     * @param file  图片
     * @param name 名称
     * @return
     */
    @PostMapping("/registered")
    public R registered(@RequestParam("avatar") MultipartFile file, @RequestParam("name") String name, @RequestParam("ownerId") Integer ownerId) throws IOException {
        BASE64Encoder base64Encoder =new BASE64Encoder();
        String base64EncoderImg = base64Encoder.encode(file.getBytes());
        String result = faceRecognition.registered(base64EncoderImg, name);
        if ("success".equals(result)) {
            Path localPath = FileUtil.resolveDirectory(uploadDir);
            String fileName=file.getOriginalFilename();
            String newFileName = FileUtil.upload(file, localPath.toString(), fileName);
            ownerInfoService.update(Wrappers.<UserInfo>lambdaUpdate().set(UserInfo::getUserImages, newFileName).eq(UserInfo::getId, ownerId));
        }
        return R.ok(result);
    }

    /**
     * 人脸搜索
     *
     * @param file 图片
     * @return
     */
    @PostMapping("/verification")
    public R verification(@RequestParam("file") String file) throws IOException {
//        BASE64Encoder base64Encoder =new BASE64Encoder();
//        String base64EncoderImg = base64Encoder.encode(file.getBytes());

        String result = faceRecognition.verification(file);
        if ("error".equals(result)) {
            return R.ok("人脸识别未通过！");
        } else {
            return R.ok("成功");
        }
    }

    /**
     * test
     * @param text
     * @return
     */
    @PostMapping("/sendFile")
    public R test(String text) throws IOException {
        BASE64Encoder base64Encoder =new BASE64Encoder();
        JSONObject jsonObject = JSONUtil.parseObj(text);
        String fileList = jsonObject.get("fileName").toString();
        Object pathObject = jsonObject.get("path");
        Path basePath = pathObject == null || pathObject.toString().trim().isEmpty()
                ? FileUtil.resolveDirectory(uploadDir)
                : FileUtil.resolveDirectory(pathObject.toString());
        // 识别人脸信息
        for (String s : fileList.split(",")) {
            String imageName = s.trim();
            System.out.println("=====>"+imageName);
            if (imageName.toLowerCase(Locale.ROOT).endsWith(".jpg")) {
                Path imagePath = basePath.resolve(imageName).normalize();
                System.out.println(imagePath);
                if (!Files.isRegularFile(imagePath)) {
                    log.warn("待识别人脸图片不存在: {}", imagePath);
                    continue;
                }
                File file = imagePath.toFile();
                try (FileInputStream inputStream = new FileInputStream(file)) {
                    MultipartFile multipartFile = new MockMultipartFile(file.getName(), file.getName(),
                            ContentType.APPLICATION_OCTET_STREAM.toString(), inputStream);
                    String result = faceRecognition.verification(base64Encoder.encode(multipartFile.getBytes()));
                    if (!"error".equals(result)) {
                        System.out.println("识别成功=====>   "+result);
                        return R.ok(result);
                    }
                }
            }
        }
        return R.ok(true);
    }

    /**
     * 人脸检测
     *
     * @param img 图片Base64码
     */
    @RequestMapping("/faceDetection")
    public R faceDetection(String img) {
        return R.ok(faceRecognition.faceDetection(img));
    }
}
