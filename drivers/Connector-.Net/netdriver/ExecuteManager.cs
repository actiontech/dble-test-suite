/*
 * Copyright (C) 2016-2022 ActionTech.
 * License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using MySql.Data.MySqlClient;

namespace netdriver
{
    class ExecuteManager
    {
        public static void Execute(String sqlfile,String[] logfiles, MySqlConnection dblemanagerconn)
        {
            //excute the sqls one by one
            int idNum = 1;
            string line;
            StreamReader sr = null;
            StreamWriter passsw = null;
            StreamWriter failsw = null;
            try
            {
                sr = new StreamReader(sqlfile);
            }
            catch (IOException ioe)
            {
                Console.WriteLine(ioe.Message);
                CleanUp.CloseStreamReader(sr);
            }
            //open log files
            try
            {
                passsw = new StreamWriter(logfiles[0], true);
            }
            catch (IOException ioe)
            {
                Console.WriteLine(ioe.Message);
                CleanUp.CloseStreamWriter(passsw);
            }

            try
            {
                failsw = new StreamWriter(logfiles[1], true);
            }
            catch (IOException ioe)
            {
                Console.WriteLine(ioe.Message);
                CleanUp.CloseStreamWriter(failsw);
            }

            while ((line = sr.ReadLine()) != null){
                if (!line.StartsWith("#"))
                {
                    String exec = "===file:" + sqlfile + ",id:" + idNum + ",sql:" + line + "===";
                    line = line.ToLower();
                    //for kill command
                    //int PID = 0;
                    //if (line.StartsWith("kill"))
                    //{
                    //    try
                    //    {
                    //        string showsql = "show @@connection;";
                    //        MySqlCommand showcmd = new MySqlCommand(showsql, dblemanagerconn);
                    //        MySqlDataReader showrdr = showcmd.ExecuteReader();
                    //        //int PID = 0;
                    //        while (showrdr.Read())
                    //        {
                    //            var pid = showrdr.GetValue(1);
                    //            PID = Convert.ToInt32(pid);
                    //            break;
                    //        }
                    //        showrdr.Close();
                    //    }
                    //    catch (MySqlException e) {

                    //    }
                    //}
                    
                    List<String> dblerslist = new List<string>();
                    try
                    {
                        MySqlCommand cmd = new MySqlCommand(line, dblemanagerconn);
                        if (dblemanagerconn.State != System.Data.ConnectionState.Open)
                        {
                            dblemanagerconn.Open();
                        }

                        MySqlDataReader rdr = cmd.ExecuteReader();
                            while (rdr.Read())
                            {
                            StringBuilder sb = new StringBuilder();
                            String column;
                            int fc = 0;
                            for (int i = 0; i < rdr.FieldCount; i++)
                            {
                                Type type = rdr.GetFieldType(rdr.GetName(i));
                                if (type.Name == "VarChar" || type.Name == "Char" || type.Name == "String" || type.Name == "Byte" || type.Name == "SByte")
                                {
                                    if (fc == (rdr.FieldCount - 1))
                                    {
                                        column = "\"" + rdr.GetValue(i) + "\"";
                                    }
                                    else
                                    {
                                        column = "\"" + rdr.GetValue(i) + "\",";
                                    }

                                }
                                else if (type.Name == "DateTime")
                                {
                                    if (fc == (rdr.FieldCount - 1))
                                    {
                                        column = "{" + rdr.GetValue(i) + "}";
                                    }
                                    else
                                    {
                                        column = "{" + rdr.GetValue(i) + "},";
                                    }
                                }
                                else
                                {
                                    if (fc == (rdr.FieldCount - 1))
                                    {
                                        column = rdr.GetValue(i).ToString();
                                    }
                                    else
                                    {
                                        column = rdr.GetValue(i) + ",";
                                    }

                                }
                                sb.Append(column);
                                fc++;
                            }
                            String linestr = "(" + sb.ToString() + "),";
                            //Console.WriteLine(linestr);
                            dblerslist.Add(linestr);
                        }
                        rdr.Close();

                        //write to logs
                        passsw.WriteLine(exec);
                        String listStr = ResultConvert.CovertListToString(dblerslist);
                        passsw.WriteLine("dble: ["+listStr+"]");
                    }
                    catch(MySqlException e)
                    {
                        String errMsg = e.Message;
                        String errCode = Convert.ToString(e.ErrorCode);
                        String errStr = "dble: [(" + errCode + ": " + errMsg + ")]";
                        failsw.WriteLine(exec);
                        failsw.WriteLine(errStr);
                    }
                }
                idNum++;
            }
            //close the opened iostream
            CleanUp.CloseStreamWriter(failsw);
            CleanUp.CloseStreamWriter(passsw);
            CleanUp.CloseStreamReader(sr);
        }
    }
}
