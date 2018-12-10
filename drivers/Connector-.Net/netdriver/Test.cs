using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

using MySql.Data;
using MySql.Data.MySqlClient;
using System.ComponentModel;


namespace netdriver
{
    class Test
    {
        public static void Testing()
        {
            string connStr = "server=10.186.60.61;user=root;port=7171;password=111111";
            MySqlConnection conn = new MySqlConnection(connStr);
            try
            {
                Console.WriteLine("Connecting to mysql...");
                conn.Open();
                string sql = "resume;";
                MySqlCommand cmd = new MySqlCommand(sql, conn);

                //object result = cmd.ExecuteScalar();
                //if (result != null)
                //{
                //    int r = Convert.ToInt32(result);
                //    Console.WriteLine(r);
                //}

                MySqlDataReader rdr = cmd.ExecuteReader();
                List<String> dblelist = new List<string>();
                while (rdr.Read())
                {
                    StringBuilder sb = new StringBuilder();
                    String line;
                    int fc = 0;
                    for (int i = 0; i < rdr.FieldCount; i++)
                    {
                        Type type = rdr.GetFieldType(rdr.GetName(i));
                        if (type.Name == "VarChar" || type.Name == "Char" || type.Name == "String" || type.Name == "Byte" || type.Name == "SByte")
                        {
                            if (fc == (rdr.FieldCount - 1))
                            {
                                line = "\"" + rdr.GetValue(i) + "\"";
                            }
                            else
                            {
                                line = "\"" + rdr.GetValue(i) + "\",";
                            }

                        }
                        else if (type.Name == "DateTime")
                        {
                            if(fc == (rdr.FieldCount - 1))
                            {
                                line = "{" + rdr.GetValue(i) + "}";
                            }
                            else
                            {
                                line = "{" + rdr.GetValue(i) + "},";
                            }
                        }
                        else
                        {
                            if (fc == (rdr.FieldCount - 1))
                            {
                                line = rdr.GetValue(i).ToString(); 
                            }
                            else
                            {
                                line = rdr.GetValue(i) + ","; 
                            }
                            
                        }
                        sb.Append(line);
                        fc++;
                    }
                    Console.WriteLine(sb.ToString());
                    String linestr = "(" + sb.ToString() + "),";
                    Console.WriteLine(linestr);
                    dblelist.Add(linestr);

                }
                String strr = ResultConvert.CovertListToString(dblelist);
                Console.WriteLine(strr);
                rdr.Close();
            }
            catch (MySqlException ex)
            {

                Console.WriteLine(ex.Number + ":" + ex.Message);
            }
            catch (Exception e)
            {
                if (e is MySqlException)
                {
                    var ee = e as MySqlException;
                    //ee.Number;
                }
                e.ToString();
            }
            conn.Close();
            Console.WriteLine("Done.");
        }
    }
}
