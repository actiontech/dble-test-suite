/*
 * Copyright (C) 2016-2021 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
package com.actiontech;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.yaml.snakeyaml.*;

import java.io.File;
import java.io.FileInputStream;
import java.util.Map;
import java.io.IOException;
import java.io.FileNotFoundException;


public class yamlParser {
    public static Config getConfig(String filepath) {
        Config cfg = new Config();
        FileInputStream fileInputStream = null;
        try {
            Yaml yaml = new Yaml();
            File f = new File(filepath);
            fileInputStream = new FileInputStream(f);
            Map map = yaml.loadAs(fileInputStream, Map.class);//装载的对象，这里使用Map, 当然也可使用自己写的对象

            //for dble
            Object cfg_dble = map.get("cfg_dble");
            ObjectMapper oMapperdble = new ObjectMapper();
            Map<String, Object> cdble = oMapperdble.convertValue(cfg_dble, Map.class);
            Object client_port = cdble.get("client_port");
            cfg.dble_port = client_port.toString();
            Object client_user = cdble.get("client_user");
            cfg.dble_user = client_user.toString();
            Object client_password = cdble.get("client_password");
            cfg.dble_password = client_password.toString();
            //manager
            Object manager_port = cdble.get("manager_port");
            cfg.dbleM_port = manager_port.toString();
            Object manager_user = cdble.get("manager_user");
            cfg.dbleM_user = manager_user.toString();
            Object manager_password = cdble.get("manager_password");
            cfg.dbleM_password = manager_password.toString();

            Object dble = cdble.get("dble");
            ObjectMapper oMapperdblecm = new ObjectMapper();
            Map<String, Object> dbleip = oMapperdblecm.convertValue(dble, Map.class);
            Object dble_ip = dbleip.get("ip");
            cfg.dble_server = dble_ip.toString();
            cfg.dbleM_server = dble_ip.toString();

            //for mysql
            Object cfg_mysql = map.get("cfg_mysql");
            ObjectMapper oMappermysql = new ObjectMapper();
            Map<String, Object> cmysql = oMappermysql.convertValue(cfg_mysql, Map.class);
            Object user = cmysql.get("user");
            Object password = cmysql.get("password");
            cfg.mysql_user = user.toString();
            cfg.mysql_password = password.toString();

            Object compare_mysql = cmysql.get("compare_mysql");
            ObjectMapper oMappercom = new ObjectMapper();
            Map<String, Object> compare = oMappercom.convertValue(compare_mysql, Map.class);
            Object master1 = compare.get("master1");
            ObjectMapper oMappermaster1 = new ObjectMapper();
            Map<String, Object> mtr1 = oMappermaster1.convertValue(master1, Map.class);
            Object mysql_ip = mtr1.get("ip");
            Object mysql_port = mtr1.get("port");
            cfg.mysql_server = mysql_ip.toString();
            cfg.mysql_port = mysql_port.toString();

            Object cfg_sys = map.get("cfg_sys");
            ObjectMapper oMappersys = new ObjectMapper();
            Map<String, Object> csys = oMappersys.convertValue(cfg_sys, Map.class);
            Object default_db = csys.get("default_db");
            Object sql_source = csys.get("sql_source");
            cfg.db = default_db.toString();
            cfg.sqlpath = sql_source.toString();
        } catch (FileNotFoundException e) {
//            log.error("file address error!");
            e.printStackTrace();
            System.exit(-1);
        } finally {
            try {
                if (fileInputStream != null) fileInputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
                System.exit(-1);
            }
        }
        return cfg;
    }
}