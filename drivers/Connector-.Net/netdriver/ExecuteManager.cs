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
            //读取文件，循环执行sql
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
            //打开log文件
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
                failsw = new StreamWriter(logfiles[1].ToString(), true);
            }
            catch (IOException ioe)
            {
                Console.WriteLine(ioe.Message);
                CleanUp.CloseStreamWriter(failsw);
            }

            if ((sr == null) || (passsw == null) || (failsw == null))
            {
                return;
            }

            while ((line = sr.ReadLine()) != null){
                if (!line.StartsWith("#"))
                {
                    String exec = "===File:" + sqlfile + ",id:" + idNum + ",sql:" + line + "===";
                    line = line.ToLower();
                    List<String> dblerslist = new List<string>();
                    try
                    {
                        MySqlCommand cmd = new MySqlCommand(line, dblemanagerconn);
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

                        //写入log
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
            //关闭打开的流
            CleanUp.CloseStreamWriter(failsw);
            CleanUp.CloseStreamWriter(passsw);
            CleanUp.CloseStreamReader(sr);
        }
    }
}
