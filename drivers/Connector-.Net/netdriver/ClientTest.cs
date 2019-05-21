/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
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
                    //create log files as per the name of sql file
                    String sqlpath = Csqlfiles[i];
                    String sqlfilename = Path.GetFileNameWithoutExtension(sqlpath);
                    String passlogname = sqlfilename + "_pass.log";
                    String faillogname = sqlfilename + "_fail.log";
                    String[] logfilenames = { passlogname, faillogname };
                    String[] logfiles = CreateFile.CreateFiles(logpath, logfilenames,true);

                    SetUp.IniFile("test1.txt");
                    //excute the sqls, compare and write the results to log files
                    ExecuteClient.Execute(Csqlfiles[i], logfiles, dbleconn, mysqlconn);
                    CleanUp.Rmfile("test1.txt");
                }
                //close db connections
                CleanUp.CloseConnection(dbleconn);
                CleanUp.CloseConnection(mysqlconn);
            }
        }
    }
}
