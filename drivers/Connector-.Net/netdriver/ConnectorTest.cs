/*
 * Copyright (C) 2016-2022 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;
using System.IO;
using static System.Net.Mime.MediaTypeNames;

namespace netdriver
{
    class ConnectorTest
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="args"></param>
        //static void Main(string[] args)
        static void Main(string[] args)
        {
            //Test.Testing();
            string dbleconnStr;
            string mysqlconnStr;
            string dblemanagerconnStr;
            //Config cfg;
            Config cfg = new Config();
            String[] Msqlfile;
            String[] Csqlfile;

            //get timestamp
            TimeSpan ts = DateTime.Now - new DateTime(1970, 1, 1, 0, 0, 0, 0);
//            String tsp = Convert.ToInt64(ts.TotalSeconds).ToString();
            String dirName = "sql_logs";
            //String curpath = Directory.GetCurrentDirectory();
            String curpath = Environment.CurrentDirectory;
            String logpath = Path.Combine(curpath, dirName);

            if (args[0] == "test")
            {
                dbleconnStr = "server=10.186.60.61;user=test;database=schema1;port=7131;password=111111;Charset=utf8";
                mysqlconnStr = "server=10.186.60.61;user=test;database=schema1;port=7144;password=111111;Charset=utf8";
                dblemanagerconnStr = "server=10.186.60.61;user=root;port=7171;password=111111;Charset=utf8";

                //String[] testargs = new String[]{ "D:\\NetConnector\\netdriver\\bin\\Release\\sql_cover\\driver_test_client.sql","D:\\NetConnector\\netdriver\\bin\\Release\\sql_cover\\driver_test_manager.sql" };
                Msqlfile = new String[] { "D:\\NetConnector\\netdriver\\sql cover\\driver_test_manager.sql" };
                Csqlfile = new String[] { "D:\\NetConnector\\netdriver\\bin\\Release\\sql_cover\\driver_test_client.sql" };
            }
            else {
                cfg = GetConfig.GetYamlConfig(args[1]);
                dbleconnStr = "server="+ cfg.dble_server + ";user=" + cfg.dble_user + ";database=" + cfg.db + ";port=" + cfg.dble_port + ";password=" + cfg.dble_password + ";Charset=utf8";
                dblemanagerconnStr = "server=" + cfg.dbleM_server + ";user=" + cfg.dbleM_user + ";port=" + cfg.dbleM_port + ";password=" + cfg.dbleM_password + ";Charset=utf8";
                mysqlconnStr = "server=" + cfg.mysql_server + ";user=" + cfg.mysql_user + ";database=" + cfg.db + ";port=" + cfg.mysql_port + ";password=" + cfg.mysql_password + ";Charset=utf8";
                //cfg.sqlpath = "sql_cover";
                String Msqlpath = Path.Combine(cfg.sqlpath, args[2]);
                String Csqlpath = Path.Combine(cfg.sqlpath, args[3]);
                Msqlfile = new String[] { Msqlpath };
                Csqlfile = new String[] { Csqlpath };
            }

            //get the execute sql file
            List<String> Msqlfiles = GetFile.GetFiles(Msqlfile);
            List<String> Csqlfiles = GetFile.GetFiles(Csqlfile);

            if (Msqlfiles.Count <= 0 && Csqlfiles.Count <= 0)
            {
                Console.WriteLine("There is no testing file，please check the config!");
                //return;
                Environment.Exit(-1);
            }
         
            //execute with client sqls
            if (Csqlfiles.Count > 0)
            {
                ClientTest.CTest(dbleconnStr,mysqlconnStr, Csqlfiles,logpath);
            }
            //execute with manager sqls
            if (Msqlfiles.Count > 0)
            {
                ManagerTest.MTest(dblemanagerconnStr, Msqlfiles, logpath);
            }

            Environment.Exit(0);
            //Application.Exit();
        }
    }
}