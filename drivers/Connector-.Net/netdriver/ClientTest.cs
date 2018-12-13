using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;

namespace netdriver
{
    class ClientTest
    {
        public static void CTest(string dbleconnStr, string mysqlconnStr, List<String> Csqlfiles,String logpath)
        {
            MySqlConnection dbleconn = Conn.MySQLConn(dbleconnStr);
            MySqlConnection mysqlconn = Conn.MySQLConn(mysqlconnStr);
            if (dbleconn != null && mysqlconn != null)
            {
                for (int i = 0; i < Csqlfiles.Count; i++)
                {
                    //获取需要执行的sql文件名,生成对应的log文件
                    String sqlpath = Csqlfiles[i];
                    String sqlfilename = Path.GetFileNameWithoutExtension(sqlpath);
                    String passlogname = sqlfilename + "_pass.log";
                    String faillogname = sqlfilename + "_fail.log";
                    String[] logfilenames = { passlogname, faillogname };
                    String[] logfiles = CreateFile.CreateFiles(logpath, logfilenames);

                    SetUp.IniFile("test1.txt");
                    //执行sql,比对结果并写入文件
                    ExecuteClient.Execute(Csqlfiles[i], logfiles, dbleconn, mysqlconn);
                    CleanUp.Rmfile("test1.txt");
                }
                //关闭数据库链接
                CleanUp.CloseConnection(dbleconn);
                CleanUp.CloseConnection(mysqlconn);
            }
        }
    }
}
