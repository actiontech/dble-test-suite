//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"


void case_mysql_set_server_option(MYSQL* conn)
{
	printf("==>mysql_set_server_option test suites\n");

    const char* sql="select count(*) from sharding_4_t1";

    if(mysql_set_server_option(conn,MYSQL_OPTION_MULTI_STATEMENTS_ON)){
        printf("set mysql_set_server_option get err:%s\n", mysql_error(conn));
		exit(1);
    }else{
        int status = mysql_query(conn, "DROP TABLE IF EXISTS sharding_4_t1;\
	                      CREATE TABLE sharding_4_t1(id INT);");
	    if (status)
		{
		  printf("set mysql_set_server_option Could not execute multi statement(s)\n");
		  exit(1);
		}else{
			do {
				MYSQL_RES  *result = mysql_store_result(conn);
				if (result)
				{
					mysql_free_result(result);
				}
				if ((status = mysql_next_result(conn)) > 0){
		            printf("Could not execute statement\n");
		            exit(1);
				}
			} while (status == 0);

			doQueryWithExpectInt(conn, const_cast<char*>(sql), 0);
			mysql_set_server_option(conn, MYSQL_OPTION_MULTI_STATEMENTS_OFF);
			printf("    pass! after mysql_set_server_option MYSQL_OPTION_MULTI_STATEMENTS_ON, execute mult-query success!\n");

		}
    }
}
