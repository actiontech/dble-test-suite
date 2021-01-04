/*
 * Copyright (C) 2016-2021 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text;
//using System.Threading.Tasks;
//using MySql.Data.MySqlClient;
//using System.IO;


//namespace netdriver
//{
//    class Program
//    {
//        /// <summary>
//        /// 
//        /// </summary>
//        /// <param name="args"></param>
//        static void Main(string[] args)
//        {
//            //String ConnStr = GetConfig.GetYamlConfig("E:\\NetConnector\\netdriver\\Properties\\auto_dble_test.yaml","mysql");//改成传参的方式
//            //Test.Testing();
//            //链接数据库
//            //getconfig.GetConfig();
//            string dbleconnStr = "server=10.186.60.61;user=test;database=schema1;port=7131;password=111111;Charset=utf8";
//            string mysqlconnStr = "server=10.186.60.61;user=test;database=schema1;port=7144;password=111111;Charset=utf8";
//            string dblemanagerconnStr = "server=10.186.60.61;user=root;port=7171;password=111111;Charset=utf8";
//            //string dblemanagerconnStr = "server=192.168.2.166;user=man1;port=9066;password=654321";
//            //MySqlConnection dblemanagerconn = conn.Conn(dblemanagerconnStr);

//            //读取sql文件循环执行文件
//            //String[] testargs = new String[]{ "D:\\NetConnector\\netdriver\\bin\\Release\\sql_cover\\driver_test_client.sql","D:\\NetConnector\\netdriver\\bin\\Release\\sql_cover\\driver_test_manager.sql" };
//            //String[] testargs = new String[]{ "D:\\NetConnector\\netdriver\\sql cover\\driver_test_manager.sql" };
//            String[] testargs = new String[]{ "D:\\NetConnector\\netdriver\\bin\\Release\\sql_cover\\driver_test_client.sql" };
//            List<String> sqlfiles = GetFile.GetFiles(testargs);

//            if (sqlfiles.Count <= 0)
//            {
//                Console.WriteLine("There is no testing file，please check the config!");
//                return;
//            }
//            //获取时间戳
//            TimeSpan ts = DateTime.Now - new DateTime(1970, 1, 1, 0, 0, 0, 0);
//            String tsp = Convert.ToInt64(ts.TotalSeconds).ToString();
//            //String curpath = Directory.GetCurrentDirectory();
//            String curpath = Environment.CurrentDirectory;
//            String logpath = Path.Combine(curpath, tsp);

//            for (int i = 0; i < sqlfiles.Count; i++)
//            {
//                //获取需要执行的sql文件名,生成对应的log文件
//                String sqlpath = sqlfiles[i];
//                String sqlfilename = Path.GetFileNameWithoutExtension(sqlpath);
//                String passlogname = sqlfilename + "_pass.log";
//                String faillogname = sqlfilename + "_fail.log";
//                String[] logfilenames = { passlogname, faillogname };
//                String[] logfiles = CreateFile.CreateFiles(logpath, logfilenames);

//                if (sqlfiles[i].Contains("client")) //执行client端sqls
//                {
//                    MySqlConnection dbleconn = Conn.MySQLConn(dbleconnStr);
//                    MySqlConnection mysqlconn = Conn.MySQLConn(mysqlconnStr);
//                    if (dbleconn != null && mysqlconn != null)
//                    {
//                        SetUp.IniFile("test1.txt");
//                        //执行sql,比对结果并写入文件
//                        ExecuteClient.Execute(sqlfiles[i], logfiles, dbleconn, mysqlconn);
//                        CleanUp.Rmfile("test1.txt");
//                    }
//                    //关闭数据库链接
//                    CleanUp.CloseConnection(dbleconn);
//                    CleanUp.CloseConnection(mysqlconn);
//                }
//                else
//                {
//                    MySqlConnection dblemanagerconn = Conn.MySQLConn(dblemanagerconnStr);
//                    if (dblemanagerconn != null)
//                    {
//                        ExecuteManager.Execute(sqlfiles[i], logfiles, dblemanagerconn);
//                    }
//                    //关闭数据库链接
//                    CleanUp.CloseConnection(dblemanagerconn);
//                }
//            }

//        }
//    }
//}
