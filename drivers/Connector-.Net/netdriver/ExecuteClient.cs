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
                Environment.Exit(-1);
            }
            //open the log files
            try
            {
                passsw = new StreamWriter(logfiles[0], true);
            }
            catch (IOException ioe)
            {
                Console.WriteLine(ioe.Message);
                CleanUp.CloseStreamWriter(passsw);
                Environment.Exit(-1);
            }

            try
            {
                failsw = new StreamWriter(logfiles[1], true);
            }
            catch (IOException ioe)
            {
                Console.WriteLine(ioe.Message);
                CleanUp.CloseStreamWriter(failsw);
                Environment.Exit(-1);
            }

            while ((line = sr.ReadLine()) != null)
            {
                if (!line.StartsWith("#"))
                {
                    bool allow_diff = false;
                    if (line.Contains("allow_diff"))
                    {
                        allow_diff = true;
                    }

                    String exec = "===File:" + sqlfile + ",id:" + idNum + ",sql:" + line + "===";
                    line = line.ToLower().Trim();
                    //dble
                    List<String> dblerslist = new List<string>();
                    try
                    {

                        MySqlCommand dblecmd = new MySqlCommand(line, dbleconn);
                        if (dbleconn.State != System.Data.ConnectionState.Open) {
                            dbleconn.Open();
                        }
                            

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

                    //mysql
                    List<String> mysqlrslist = new List<string>();
                    try
                    {

                        MySqlCommand mysqlcmd = new MySqlCommand(line, mysqlconn);
                        if (mysqlconn.State != System.Data.ConnectionState.Open)
                        {
                            mysqlconn.Open();
                        }

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

                    //compare and write to logs
                    bool same = CompareRs.CompareRS(dblerslist, mysqlrslist, allow_diff);
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
            //close the opened iostream
            CleanUp.CloseStreamWriter(failsw);
            CleanUp.CloseStreamWriter(passsw);
            CleanUp.CloseStreamReader(sr);

        }
    }
}
