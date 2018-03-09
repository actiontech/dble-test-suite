//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

//mysql_reset_connection don't support at present, reference to http://10.186.18.25/universe/uproxy/issues/241
void case_mysql_reset_connection(MYSQL* conn){
	printf("==>mysql_reset_connection test suites\n");
	char sql[100];

    strcpy(sql, "drop table if exists tx_tb");
    myquery(mysql_query(conn, sql),conn);

    strcpy(sql, "create table tx_tb(id int)");
    myquery(mysql_query(conn, sql),conn);

    strcpy(sql, "set @@autocommit = 0");
    myquery(mysql_query(conn, sql),conn);

	strcpy(sql, "insert into tx_tb values(1)");
    myquery(mysql_query(conn, sql),conn);

	//case:Any active transactions are rolled back and autocommit mode is reset.
    if (mysql_reset_connection(conn)){
        fprintf(stderr, "Failed to reset connection.  Error: %s\n", mysql_error(conn));
        exit(1);
    }else{
        printf("    *****pass! mysql_reset_connection success!*****\n");
        //case:check mysql_change_user, always performs a ROLLBACK of any active transactions
        strcpy(sql, "select count(*) from tx_tb");
        doQueryWithExpectInt(conn, sql, 0);
        printf("    pass! after reset conn, insert in uncommited trx before is not readable: %s\n", sql);

        strcpy(sql, "select 1 /*uproxy_dest_expect:S*/");
        doQueryWithExpectInt(conn, sql, 1);
        printf("    pass! after reset conn, read-write-split work fine\n");

        strcpy(sql, "select @@autocommit");
        doQueryWithExpectInt(conn, sql, 1);
        printf("    pass! after reset conn, session variables set before is reset to default!\n");
    }

}

