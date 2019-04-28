//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_get_host_info(MYSQL* mysql){
	printf("==>mysql_get_host_info && mysql_get_options && mysql_get_proto_info test suits\n");

	const char *host_info = mysql_get_host_info(mysql);
	printf("    pass! mysql_get_host_info,host info: %s\n", host_info);

	my_bool reconnect;
	if (mysql_get_option(mysql, MYSQL_OPT_RECONNECT, &reconnect)){
        fprintf(stderr, "mysql_get_options() failed\n");
        exit(1);
	}
	else{
		printf("    pass! mysql_get_options \n");
	}

	unsigned int proto_v = mysql_get_proto_info(mysql);
	printf("    pass! mysql_get_proto_info, protocol version: %ud\n", proto_v);

	const char * cipher = mysql_get_ssl_cipher(mysql);
	printf("    pass! mysql_get_ssl_cipher,conn cipher: %s\n", cipher);

}
