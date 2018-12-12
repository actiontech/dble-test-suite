using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;
using System.IO;

namespace netdriver
{
    class ExecuteClient
    {
        public static void Execute(String sqlfile, String[] logfiles, MySqlConnection dbleconn, MySqlConnection mysqlconn)
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

            while ((line = sr.ReadLine()) != null)
            {
                if (!line.StartsWith("#"))
                {
                    bool allow_diff_sequence = false;
                    if (line.Contains("allow_diff_sequence"))
                    {
                        allow_diff_sequence = true;
                    }

                    String exec = "===File:" + sqlfile + ",id:" + idNum + ",sql:" + line + "===";
                    line = line.ToLower().Trim();
                    //dble执行
                    List<String> dblerslist = new List<string>();
                    try
                    {

                        MySqlCommand dblecmd = new MySqlCommand(line, dbleconn);

                        if (line.Contains("insert") || line.Contains("update") || line.Contains("delete"))
                        {
                            int count = dblecmd.ExecuteNonQuery();
                            String countStr = Convert.ToString(count);
                            dblerslist.Add(countStr);
                        }
                        else if (line.StartsWith("select") || line.StartsWith("show") || line.StartsWith("check") || line.Contains("union"))
                        {
                            MySqlDataReader rdr = dblecmd.ExecuteReader();
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
                        }
                        else
                        {
                            object result = dblecmd.ExecuteScalar();
                            if (result == null)
                            {
                                dblerslist.Add("null");
                            }
                            else
                            {
                                String resultstr = Convert.ToString(result);
                                dblerslist.Add(resultstr);
                            }
                        }
                    }
                    catch (MySqlException ex)
                    {
                        String errMsg = ex.Number + ": " + ex.Message;
                        dblerslist.Add(errMsg);
                    }

                    //mysql执行
                    List<String> mysqlrslist = new List<string>();
                    try
                    {

                        MySqlCommand mysqlcmd = new MySqlCommand(line, mysqlconn);
                        if (line.Contains("insert") || line.Contains("update") || line.Contains("delete"))
                        {
                            int count = mysqlcmd.ExecuteNonQuery();
                            String countStr = Convert.ToString(count);
                            mysqlrslist.Add(countStr);
                        }
                        else if (line.StartsWith("select") || line.StartsWith("show") || line.StartsWith("check") || line.Contains("union"))
                        {
                            MySqlDataReader rdr = mysqlcmd.ExecuteReader();
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
                                mysqlrslist.Add(linestr);
                            }
                            rdr.Close();
                        }
                        else
                        {
                            object result = mysqlcmd.ExecuteScalar();
                            if (result == null)
                            {
                                mysqlrslist.Add("null");
                            }
                            else
                            {
                                String resultstr = Convert.ToString(result);
                                mysqlrslist.Add(resultstr);
                            }
                        }
                    }
                    catch (MySqlException ex)
                    {
                        String errMsg = ex.Number + ": " + ex.Message;
                        mysqlrslist.Add(errMsg);
                    }

                    //对比并写入log
                    bool same = CompareRs.CompareRS(dblerslist, mysqlrslist, allow_diff_sequence);
                    if (same)
                    {
                        passsw.WriteLine(exec);
                        String pass = ResultConvert.CovertListToString(dblerslist);
                        String passstr = "dble: [(" + pass + ")]";
                        passsw.WriteLine(passstr);
                    }
                    else
                    {
                        String dblefailstr = ResultConvert.CovertListToString(dblerslist);
                        String mysqlfailstr = ResultConvert.CovertListToString(mysqlrslist);
                        String failstr = "dble: [(" + dblefailstr + ")]\r\nmysql: [(" + mysqlfailstr + ")]";
                        failsw.WriteLine(exec);
                        failsw.WriteLine(failstr);
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
