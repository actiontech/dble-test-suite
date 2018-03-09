//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_change_user(MYSQL* conn){
	cout << "==>mysql_change_user test suits" << endl;

    char sql[100];
    strcpy(sql, "drop database if exists db_test1");
//    printf("query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    strcpy(sql, "create database db_test1");
//    printf("query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    strcpy(sql, "PREPARE stmt1 FROM 'SELECT SQRT(POW(?,2) + POW(?,2)) AS hypotenuse'");
//    printf("query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    strcpy(sql, "set @a=3");
//    printf("query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    strcpy(sql, "set @b=4");
//    printf("query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    if (mysql_change_user(conn, TEST_USER, TEST_USER_PASSWD, "db_test1")){
        fprintf(stderr, "Failed to change user.  Error: %s\n", mysql_error(conn));
        exit(1);
    }else{
        printf("    *****pass! change user success during read ps statement!*****\n");

        //case:mysql_change_user change default db
        strcpy(sql, "select * from ");
        strcat(sql, TEST_TABLE);
//        printf("query: %s\n", sql);
        if(mysql_query(conn, sql)){
           printf("    pass! After change user, the new db has no tables\n");
        }else{
           printf(" After change user, the new db has no tables, '%s' expect run into err\n", sql);
           exit(1);
        }

        //case:user variables is on old connection are released
        strcpy(sql, "select @a");
//        printf("query: %s\n", sql);
        doQueryWithExpectInt(conn, sql, -9999);
        printf("    pass! After change user, uv set before is no longer available.\n");

        //case:prepare statement on old connection are released
        strcpy(sql, "EXECUTE stmt1 USING @a, @b");
//        printf("query: %s\n", sql);
        if(mysql_query(conn, sql)){
            fprintf(stderr, "    pass! execute ps created before change user failed. Error: %s\n", mysql_error(conn));
        }else{
            printf("Expect 'No database selected' Error, but query success!");
            exit(1);
        }
    }

    strcpy(sql, "create table tx_tb(id int)");
//    printf("query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    strcpy(sql, "start transaction");
//    printf("    query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    strcpy(sql, "insert into tx_tb values(1)");
//    printf("    query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    if (mysql_change_user(conn, TEST_USER, TEST_USER_PASSWD, NULL)){
        fprintf(stderr, "Failed to change user without default db.  Error: %s\n", mysql_error(conn));
        exit(1);
    }else{
        printf("    *****pass! change user success at no default db conn during trx!*****\n");

        //case:mysql_change_user with no default db success
        strcpy(sql, "show tables");
//        printf("    query: %s\n", sql);
        if(mysql_query(conn, sql)){
            fprintf(stderr, "    pass! after change user, show tables failed. Error: %s\n", mysql_error(conn));
        }else{
            printf("Expect 'No database selected' Error, but query success!\n");
            exit(1);
        }

        //case:check mysql_change_user, always performs a ROLLBACK of any active transactions
        strcpy(sql, "select count(*) from db_test1.tx_tb");
//        printf("    query: %s\n", sql);
        doQueryWithExpectInt(conn, sql, 0);
        printf("    pass! select x from a_table_rows_filled_in_uncommited_trx get 0 rows. \n");

        strcpy(sql, "select 1 /*uproxy_dest_expect:S*/");
//        printf("    query: %s\n", sql);
        doQueryWithExpectInt(conn, sql, 1);
        printf("    pass! before change user the conn is in CM stat, after change user, the stat over\n");
    }

    strcpy(sql, "create temporary table db_test1.tmp_tb(id int)");
//    printf("    query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    if (mysql_change_user(conn, TEST_USER, TEST_USER_PASSWD, "db_test1")){
        fprintf(stderr, "Failed to change user.  Error: %s\n", mysql_error(conn));
        exit(1);
    }else{
        printf("    *****pass! change user success after create tmp table!*****\n");

        //case:mysql_change_user drops all temporary tables
        strcpy(sql, "select 1 /*uproxy_dest_expect:S*/");
//        printf("    query: %s\n", sql);
        doQueryWithExpectInt(conn, sql, 1);
        printf("    pass! before change user the conn is in CM stat, after change user, the stat over\n");

        strcpy(sql, "select * from db_test1.tmp_tb");
//        printf("    query: %s\n", sql);
        if(mysql_query(conn, sql)){
            fprintf(stderr, "    pass! a tmp table created before change user is no longer exist! Error: %s\n", mysql_error(conn));
        }else{
            printf("Expect temp table dropped, but query success!\n");
            exit(1);
        }
    }

    strcpy(sql, "create table db_test1.lock_tb(id int)");
//    printf("    query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    strcpy(sql, "lock table db_test1.lock_tb write");
//    printf("    query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    if (mysql_change_user(conn, TEST_USER, TEST_USER_PASSWD, "db_test1")){
        fprintf(stderr, "Failed to change user.  Error: %s\n", mysql_error(conn));
        exit(1);
    }else{
        printf("    *****pass! change user success after lock table!*****\n");
        //case:mysql_change_user unlocks all locked tables
        strcpy(sql, "insert into db_test1.lock_tb values(1)");
//        printf("    query: %s\n", sql);
        myquery(mysql_query(conn, sql), conn);
        printf("    pass! after change user, the lock on the table before change user is released! \n");

        //case:restore read-write-split
        strcpy(sql, "select 1 /*uproxy_dest_expect:S*/");
//        printf("query: %s\n", sql);
        doQueryWithExpectInt(conn, sql, 1);
        printf("    pass! before change user the conn is in CM stat, after change user, the stat over\n");
    }

    strcpy(sql, "set @@session.bulk_insert_buffer_size=8389632");
//    printf("    query: %s\n", sql);
    myquery(mysql_query(conn, sql), conn);

    if (mysql_change_user(conn, TEST_USER, TEST_USER_PASSWD, "db_test1")){
        fprintf(stderr, "Failed to change user.  Error: %s\n", mysql_error(conn));
        exit(1);
    }else{
        printf("    *****pass! change user success after set session system variables!*****\n");

        //case:Session system variables are reset to the values of the corresponding global system variables
        strcpy(sql, "select @@session.bulk_insert_buffer_size");
//        printf("query: %s\n", sql);
        doQueryWithExpectInt(conn, sql, 8388608);
        printf("    pass! after change user,a session variable changed before change user is reset to default value\n");
    }
}
