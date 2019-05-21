/*
 * Copyright (C) 2016-2019 ActionTech.
 * License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
 */
using System;
using System.Data;

using MySql.Data;
using MySql.Data.MySqlClient;

namespace netdriver
{
    class Conn
    {
        public static MySqlConnection MySQLConn(string connStr)
        {
            MySqlConnection conn = null;
            conn = new MySqlConnection(connStr);
            try
            {
                Console.WriteLine("Connecting to "+ connStr + " ...");
                conn.Open();
                // Perform database operations
                Console.WriteLine("Connectted");
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                Console.WriteLine("open conn failed");
                conn.Close();
                conn = null;
                Environment.Exit(-1);
            }
            return conn;
        }
    }
}