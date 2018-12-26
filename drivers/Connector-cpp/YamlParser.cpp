#include "yaml-cpp/yaml.h" #include <iostream>#include <fstream>#include <string>#include <vector>#include <sstream>
#include "config.h"
using namespace std;
using namespace YAML;

Config YParse(string yamlpath, string dockername, string client) {
	Config cfg;
	string port;
	try {
		Node doc = LoadFile(yamlpath);		cfg.name = doc["services"][dockername]["networks"]["net"]["ipv4_address"].as<string>();
		port = doc["services"][dockername]["ports"][0].as<string>();
		cfg.port = port.substr(0, port.find(":"));
		//cfg.user = "test";
		cfg.passwd = "111111";
		cout << cfg.name << endl;
		cout << cfg.port << endl;
		return cfg;
	}
	catch (Exception &e) {
		cout << e.what() << endl;
		exit(1);
	}

}