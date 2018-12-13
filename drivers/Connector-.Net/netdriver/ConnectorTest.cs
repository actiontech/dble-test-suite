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
        static void Main(string[] args)
        {
            //String ConnStr = GetConfig.GetYamlConfig("E:\\NetConnector\\netdriver\\Properties\\auto_dble_test.yaml","mysql");//改成传参的方式
            //Test.Testing();
            //链接数据库
            //getconfig.GetConfig();
            string dbleconnStr = "server=10.186.60.61;user=test;database=mytest;port=7131;password=111111;Charset=utf8";
            string mysqlconnStr = "server=10.186.60.61;user=test;database=mytest;port=7144;password=111111;Charset=utf8";
            string dblemanagerconnStr = "server=10.186.60.61;user=root;port=7171;password=111111;Charset=utf8";
            //string dblemanagerconnStr = "server=192.168.2.166;user=man1;port=9066;password=654321";
            //MySqlConnection dblemanagerconn = conn.Conn(dblemanagerconnStr);

            //获取sql执行文件
            //String[] testargs = new String[]{ "D:\\NetConnector\\netdriver\\bin\\Release\\sql_cover\\driver_test_client.sql","D:\\NetConnector\\netdriver\\bin\\Release\\sql_cover\\driver_test_manager.sql" };
            String[] Msqlfile = new String[] { "D:\\NetConnector\\netdriver\\sql cover\\driver_test_manager.sql" };
            String[] Csqlfile = new String[] { "D:\\NetConnector\\netdriver\\bin\\Release\\sql_cover\\driver_test_client.sql" };
            List<String> Msqlfiles = GetFile.GetFiles(Msqlfile);
            List<String> Csqlfiles = GetFile.GetFiles(Csqlfile);

            if (Msqlfiles.Count <= 0 && Csqlfiles.Count <= 0)
            {
                Console.WriteLine("There is no testing file，please check the config!");
                return;
            }
            //获取时间戳
            TimeSpan ts = DateTime.Now - new DateTime(1970, 1, 1, 0, 0, 0, 0);
            String tsp = Convert.ToInt64(ts.TotalSeconds).ToString();
            //String curpath = Directory.GetCurrentDirectory();
            String curpath = Environment.CurrentDirectory;
            String logpath = Path.Combine(curpath, tsp);

            //执行client端sqls
            if (Csqlfiles.Count > 0)
            {
                ClientTest.CTest(dbleconnStr,mysqlconnStr, Csqlfiles,logpath);
            }
            //执行管理端sqls
            if (Msqlfiles.Count > 0)
            {
                ManagerTest.MTest(dblemanagerconnStr, Msqlfiles, logpath);
            }

            //正常退出
            //System.Environment.Exit(0);
            //Application.Exit();
        }
    }
}