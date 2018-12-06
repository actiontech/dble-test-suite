package com.actiontech;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.yaml.snakeyaml.*;
import java.io.File;
import java.io.FileInputStream;
import java.util.Map;
import java.io.IOException;
import java.io.FileNotFoundException;


public class yamlParser {
    public static Object getConfig(String filepath, String configName) {
        FileInputStream fileInputStream = null;
        try {
            Yaml yaml = new Yaml();
            File f = new File(filepath);
            fileInputStream = new FileInputStream(f);
            Map map = yaml.loadAs(fileInputStream, Map.class);//装载的对象，这里使用Map, 当然也可使用自己写的对象
            Object configobj = map.get(configName);
            return configobj;
        } catch (FileNotFoundException e) {
//            log.error("文件地址错误");
            e.printStackTrace();
            return null;
        } finally {
            try {
                if (fileInputStream != null) fileInputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            }
        }
    }

}
