package cc.mrbird.febs.common.utils;

import lombok.extern.slf4j.Slf4j;
import org.lionsoul.ip2region.DataBlock;
import org.lionsoul.ip2region.DbConfig;
import org.lionsoul.ip2region.DbSearcher;
import org.lionsoul.ip2region.Util;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

@Slf4j
public class AddressUtil {

    private static final String IP_DB_CLASSPATH = "ip2region/ip2region.db";
    private static volatile Path tempDbPath;

    public static String getCityInfo(String ip) {
        DbSearcher searcher = null;
        try {
            Path dbPath = resolveDbPath();
            int algorithm = DbSearcher.BTREE_ALGORITHM;
            DbConfig config = new DbConfig();
            searcher = new DbSearcher(config, dbPath.toString());
            Method method = null;
            method = searcher.getClass().getMethod("btreeSearch", String.class);
            DataBlock dataBlock = null;
            if (!Util.isIpAddress(ip)) {
                log.error("Error: Invalid ip address");
            }
            dataBlock = (DataBlock) method.invoke(searcher, ip);
            return dataBlock.getRegion();
        } catch (Exception e) {
            log.error("获取地址信息异常", e);
        } finally {
            if (searcher != null) {
                try {
                    searcher.close();
                } catch (IOException e) {
                    log.error("关闭 ip2region 查询器失败", e);
                }
            }
        }
        return "";
    }

    private static Path resolveDbPath() throws Exception {
        URL resource = AddressUtil.class.getClassLoader().getResource(IP_DB_CLASSPATH);
        if (resource == null) {
            throw new IOException("未找到 ip2region 数据库文件: " + IP_DB_CLASSPATH);
        }

        if ("file".equalsIgnoreCase(resource.getProtocol())) {
            return Paths.get(resource.toURI()).toAbsolutePath().normalize();
        }

        if (tempDbPath == null || Files.notExists(tempDbPath)) {
            synchronized (AddressUtil.class) {
                if (tempDbPath == null || Files.notExists(tempDbPath)) {
                    tempDbPath = Files.createTempFile("ip2region-", ".db");
                    try (InputStream inputStream = AddressUtil.class.getClassLoader().getResourceAsStream(IP_DB_CLASSPATH)) {
                        if (inputStream == null) {
                            throw new IOException("未找到 ip2region 数据库流: " + IP_DB_CLASSPATH);
                        }
                        Files.copy(inputStream, tempDbPath, StandardCopyOption.REPLACE_EXISTING);
                    }
                    tempDbPath.toFile().deleteOnExit();
                }
            }
        }
        return tempDbPath;
    }

}
