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

	if(mysql_query(conn, "select 1/*uproxy_dest_expect:M*/"))
	{
		const char * errState=mysql_sqlstate(conn);
		printf("    pass! query 'select 1/*uproxy_dest_expect:M*/', mysql_sqlstate: %s\n", errState);
	}else{
        if(!IS_DEBUG){
            printf("expect send select to master get err, but success\n");
        	exit(1);
        }
	}

	MYSQL* connAdmin = mysql_init(NULL);
    mysql_real_connect(connAdmin, Host_Test, TEST_ADMIN, TEST_ADMIN_PASSWD, TEST_DB, TEST_PORT,NULL, CLIENT_DEPRECATE_EOF);

	mysql_query(connAdmin, "uproxy add_group 'test1' '111111'");

	MYSQL* connErr = mysql_init(NULL);
    mysql_real_connect(connErr, Host_Test, "test1", TEST_USER_PASSWD, TEST_DB, TEST_PORT,NULL, CLIENT_DEPRECATE_EOF);

    if (mysql_query(connErr, "show databases")) {
		const char * errState=mysql_sqlstate(connErr);
        const char* err=mysql_error(connErr);
        if(strcmp("No master mysqld available.", err)!=0){
            printf("expect 'No master mysqld available.', but %s\n", err);
            exit(1);
        }else{
            printf("    pass! send query to uproxy admin port, mysql_sqlstate: %s\n", errState);
        }
	}else{
        printf("expect no master mysqld available, but success\n");
		exit(1);
	}
}
