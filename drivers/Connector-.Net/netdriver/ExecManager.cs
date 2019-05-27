/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace netdriver
{
    class ExecManager
    {
        public static void ExecManager(String sqlfile, String[] logfiles)
        {
            //打开文件夹并按行读取
            StreamReader sr = new StreamReader(sqlfile);
            //打开log文件
            String passlogfile = logfiles[0];
            String faillogfile = logfiles[1];
            StreamWriter passsw = new StreamWriter(passlogfile, true);
            StreamWriter failsw = new StreamWriter(faillogfile, true);
            int lineNum = 0;
            string line;
            while ((line = sr.ReadLine()) != null)
            {
                System.Console.WriteLine(line);
                String execsql = "===File:" + sqlfile + ", id: " + lineNum + ", SQL:" + line + "\r\n";
                String rslist;
                //执行管理端sql语句 todo
                try
                {
                    //rslist = 
                    passsw.WriteLine(execsql);
                    passsw.WriteLine(rslist);
                }
                catch (IOException e)
                {
                    Console.WriteLine(e);
                    failsw.Write(execsql);
                    failsw.WriteLine(rslist);
                }
                lineNum++;
            }
            //关闭文件
            failsw.Close();
            passsw.Close();
            sr.Close();
        }
    }
}
