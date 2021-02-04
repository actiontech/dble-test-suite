//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_sqlstate(MYSQL* conn)
{
	printf("==>mysql_sqlstate test suites\n");

	if(mysql_query(conn, "use schema1/*a*/"))
	{
		const char * errState=mysql_sqlstate(conn);
		printf("    pass! query 'use schema1/*a*/', success\n");
	}else{
        if(!IS_DEBUG){
            printf("expect send select to master success, but get err\n");
        	exit(1);
        }
	}

	MYSQL* connErr = mysql_init(NULL);
    mysql_real_connect(connErr, HOST_DBLE, ADMIN, ADMIN_PASSWD, "", DBLE_ADMIN_PORT, NULL, CLIENT_DEPRECATE_EOF);

    if (mysql_query(connErr, "show databases")!=0)
    {
		const char * errState=mysql_sqlstate(connErr);
        const char* err=mysql_error(connErr);
        if(strcmp("Unsupported statement", err)!=0){
            printf("expect 'success', but %s\n", err);
            exit(1);
        }else{
            printf("expect 'success',  mysql_sqlstate: %s\n", errState);
            exit(1);
        }
	}else{
	    printf("    pass! send query 'show databases' to admin port, success\n");
	}
}
