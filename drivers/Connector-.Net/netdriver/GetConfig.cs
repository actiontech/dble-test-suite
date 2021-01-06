/*
 * Copyright (C) 2016-2021 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;
using YamlDotNet.RepresentationModel;

namespace netdriver
{
    class GetConfig
    {

        public static Config GetYamlConfig(String yamlfile)
        {
            Config cfg = new Config();

            //String ConnStr;
            TextReader input = null;
            try
            {
                input = new StreamReader(yamlfile);
            }

            catch (IOException ioe)
            {
                Console.WriteLine(ioe.Message);
                //return "Parser yaml file failed!";
                System.Environment.Exit(-1);
            }

            // Load the stream
            var yaml = new YamlStream();
            yaml.Load(input);

            // Examine the stream
            var mapping = (YamlMappingNode)yaml.Documents[0].RootNode;

            var cfg_sys = mapping.Children["cfg_sys"];
            var default_db = cfg_sys["default_db"];
            cfg.db = default_db.ToString();
            var sql_source = cfg_sys["sql_source"];
            cfg.sqlpath = sql_source.ToString();
            //mysql
            var cfg_mysql = mapping.Children["cfg_mysql"];
            var mysql_user = cfg_mysql["user"];
            cfg.mysql_user = mysql_user.ToString();
            var mysql_password = cfg_mysql["password"];
            cfg.mysql_password = mysql_password.ToString();
            var compare_mysql = cfg_mysql["compare_mysql"];
            var master1 = compare_mysql["master1"];
            var mysql_ip = master1["ip"];
            cfg.mysql_server = mysql_ip.ToString();
            var mysql_port = master1["port"];
            cfg.mysql_port = mysql_port.ToString();
            //dble
            var cfg_dble = mapping.Children["cfg_dble"];
            var dble = cfg_dble["dble"];
            var dble_ip = dble["ip"];
            cfg.dbleM_server = dble_ip.ToString();
            cfg.dble_server = dble_ip.ToString();

            var client_user = cfg_dble["client_user"];
            cfg.dble_user = client_user.ToString();
            var client_password = cfg_dble["client_password"];
            cfg.dble_password = client_password.ToString();
            var client_port = cfg_dble["client_port"];
            cfg.dble_port = client_port.ToString();

            var manager_user = cfg_dble["manager_user"];
            cfg.dbleM_user = manager_user.ToString();
            var manager_password = cfg_dble["manager_password"];
            cfg.dbleM_password = manager_password.ToString();
            var manager_port = cfg_dble["manager_port"];
            cfg.dbleM_port = manager_port.ToString();

            input.Close();
            return cfg;
           
            
        }
    }
}
