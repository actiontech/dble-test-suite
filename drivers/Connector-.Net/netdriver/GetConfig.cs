using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;
using YamlDotNet.RepresentationModel;

namespace netdriver
{
    class GetConfig
    {

        public static String GetYamlConfig(String yamlfile,String client)
        {
            String ConnStr;
            TextReader input = null;
            try
            {
                input = new StreamReader(yamlfile);
            }

            catch (IOException ioe)
            {
                Console.WriteLine(ioe.Message);
                return "Parser yaml file failed!";
                
            }

            // Load the stream
            var yaml = new YamlStream();
            yaml.Load(input);

            // Examine the stream
            var mapping = (YamlMappingNode)yaml.Documents[0].RootNode;
            if (client == "mysql")
            {
                var cfg_mysql = mapping.Children["cfg_mysql"];
                var mysql_user = cfg_mysql["user"];
                String user = mysql_user.ToString();
                var mysql_password = cfg_mysql["password"];
                String password = mysql_password.ToString();
                var compare_mysql = cfg_mysql["compare_mysql"];
                var master1 = compare_mysql["master1"];
                var mysql_ip = master1["ip"];
                String ip = mysql_ip.ToString();
                var mysql_port = master1["port"];
                String port = mysql_port.ToString();
                var mysql_hostname = master1["hostname"];
                String hostname = mysql_hostname.ToString();
                ConnStr = "server="+ip+";user="+user+";database=mytest;port="+port+";password="+password+";Charset=utf8";
                input.Close();
                return ConnStr;
            }
            else
            {
                var cfg_dble = mapping.Children["cfg_dble"];
                var dble = cfg_dble["dble"];
                var dble_ip = dble["ip"];
                String ip = dble_ip.ToString();
                
                if (client == "dble")
                {
                    var client_user = cfg_dble["client_user"];
                    String Cuser = client_user.ToString();
                    var client_password = cfg_dble["client_password"];
                    String Cpassword = client_password.ToString();
                    var client_port = cfg_dble["client_port"];
                    String Cport = client_port.ToString();
                    ConnStr = "server=" + ip + ";user=" + Cuser + ";database=mytest;port=" + Cport + ";password=" + Cpassword + ";Charset=utf8";
                    input.Close();
                    return ConnStr;
                }
                else
                {
                    var manager_user = cfg_dble["manager_user"];
                    String Muser = manager_user.ToString();
                    var manager_password = cfg_dble["manager_password"];
                    String Mpassword = manager_password.ToString();
                    var manager_port = cfg_dble["manager_port"];
                    String Mport = manager_port.ToString();
                    ConnStr = "server=" + ip + ";user=" + Muser + ";database=mytest;port=" + Mport + ";password=" + Mpassword + ";Charset=utf8";
                    input.Close();
                    return ConnStr;
                }
            }
            
        }
    }
}
