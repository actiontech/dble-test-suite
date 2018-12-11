using System;
using System.Data;

using MySql.Data;
using MySql.Data.MySqlClient;

namespace netdriver
{
    class DbleManagerConn
    {
        public MySqlConnection Conn()
        {
            MySqlConnection conn = null;
            //string connStr = "server=10.186.60.61;user=manager;port=7171;password=111111";
            string connStr = "server=192.168.2.166;user=man1;port=9066;password=654321";
            conn = new MySqlConnection(connStr);
            try
            {
                Console.WriteLine("Connecting to dble manager...");
                conn.Open();
                // Perform database operations
                Console.WriteLine("Connecting to dble manager success");
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                Console.WriteLine("open dble manager failed");
                conn.Close();
                conn = null;
            }
            return conn;
        }
    }
}
