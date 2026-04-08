package cc.mrbird.febs.common.config;

import cc.mrbird.febs.common.utils.FileUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;

@Configuration
public class MyWebMvcConfigurerAdapter implements WebMvcConfigurer {

    @Value("${febs.file.upload-dir:uploads}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        Path localPath = FileUtil.resolveDirectory(uploadDir);
        String resourceLocation = localPath.toUri().toString();
        if (!resourceLocation.endsWith("/")) {
            resourceLocation = resourceLocation + "/";
        }
        registry.addResourceHandler("/imagesWeb/**").addResourceLocations(resourceLocation);
        WebMvcConfigurer.super.addResourceHandlers(registry);
    }
}
