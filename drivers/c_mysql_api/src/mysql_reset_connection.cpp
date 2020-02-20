//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_reset_connection(MYSQL* conn){
	printf("==>mysql_reset_connection test suites\n");
	char sql[100];

    strcpy(sql, "drop table if exists sharding_4_t1");
    myquery(conn, sql);

    strcpy(sql, "create table sharding_4_t1(id int)");
    myquery(conn, sql);

    strcpy(sql, "set @@autocommit = 0");
    myquery(conn, sql);

    strcpy(sql, "start transaction");
    myquery(conn, sql);

	strcpy(sql, "insert into sharding_4_t1 values(1)");
    myquery(conn, sql);

	//case:Any active transactions are rolled back and autocommit mode is reset.
    if (mysql_reset_connection(conn)){
        fprintf(stderr, "Failed to reset connection.  Error: %s\n", mysql_error(conn));
        exit(1);
    }else{
        printf("    *****pass! mysql_reset_connection success!*****\n");
        //case:check mysql_change_user, always performs a ROLLBACK of any active transactions
        strcpy(sql, "select count(*) from sharding_4_t1");
        doQueryWithExpectInt(conn, sql, 0);
        printf("    pass! after reset conn, insert in uncommited trx before is not readable: %s\n", sql);

        strcpy(sql, "select @@autocommit");
        doQueryWithExpectInt(conn, sql, 1);
        printf("    pass! after reset conn, session variables set before is reset to default!\n");
    }


    strcpy(sql, "drop table if exists schema1.lock_tb");
    myquery(conn, sql);

    strcpy(sql, "create table schema1.lock_tb(id int)");
    myquery(conn, sql);

    strcpy(sql, "lock table schema1.lock_tb write");
    myquery(conn, sql);

    if (mysql_query(conn, sql)){
        fprintf(stderr, "Failed to reset connection.  Error: %s\n", mysql_error(conn));
        exit(1);
    }else{
        printf("    *****pass! reset connection success after lock table!*****\n");
        //case: unlocks all locked tables
        strcpy(sql, "insert into schema1.lock_tb values(1)");

        myquery(conn, sql);
        printf("    pass! after reset connection, the lock on the table before reset connection is released! \n");
    }


    strcpy(sql, "PREPARE stmt1 FROM 'SELECT SQRT(POW(?,2) + POW(?,2)) AS hypotenuse'");
    myquery(conn, sql);

    strcpy(sql, "set @a=3");
    myquery(conn, sql);

    strcpy(sql, "set @b=4");
    myquery(conn, sql);

    printf("debug 1\n");

    if (mysql_reset_connection(conn)){
        fprintf(stderr, "Failed to reset connection.  Error: %s\n", mysql_error(conn));
        exit(1);
    }else{
    printf("    *****pass! reset connection success during read ps statement!*****\n");
    //case:user variables is on old connection are released
        strcpy(sql, "select @a");

        doQueryWithExpectInt(conn, sql, -9999);
        printf("    pass! After reset connection, uv set before is no longer available.\n");

        //case:prepare statement on old connection are released
        strcpy(sql, "EXECUTE stmt1 USING @a, @b");

        if(mysql_query(conn, sql)){
            fprintf(stderr, "    pass! execute ps created before reset connection failed. Error: %s\n", mysql_error(conn));
        }else{
            printf("Expect 'No database selected' Error, but query success!");
            exit(1);
        }
    }

}

