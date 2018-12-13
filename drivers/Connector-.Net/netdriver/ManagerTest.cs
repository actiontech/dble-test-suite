using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;

namespace netdriver
{
    class ManagerTest
    {
        public static void MTest(string dblemanagerconnStr, List<String> Msqlfiles, String logpath)
        {
            MySqlConnection dblemanagerconn = Conn.MySQLConn(dblemanagerconnStr);
            if (dblemanagerconn != null)
            {
                for (int i = 0; i < Msqlfiles.Count; i++)
                {
                    //获取需要执行的sql文件名,生成对应的log文件
                    String sqlpath = Msqlfiles[i];
                    String sqlfilename = Path.GetFileNameWithoutExtension(sqlpath);
                    String passlogname = sqlfilename + "_pass.log";
                    String faillogname = sqlfilename + "_fail.log";
                    String[] logfilenames = { passlogname, faillogname };
                    String[] logfiles = CreateFile.CreateFiles(logpath, logfilenames);

                    ExecuteManager.Execute(Msqlfiles[i], logfiles, dblemanagerconn);
                }
                //关闭数据库链接
                CleanUp.CloseConnection(dblemanagerconn);
            }
        }
    }
}
