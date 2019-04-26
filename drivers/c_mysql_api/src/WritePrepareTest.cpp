//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "prepare_util.h"


void wPrepareTest() {
	printf("==>write prepare statement related test suites\n");

    /* Bind the data for all 3 parameters */
    memset(wbind, 0, sizeof(wbind));
    MYSQL *conn = getConn();

	createTable(conn);

    MYSQL_STMT *stmt = create_wstmt_and_prepare(conn);

//*****case1:during master prepare, select should be sent to slave
    printf("debug 1\n");
    myquery(conn, slave_sql);
    printf("debug 2\n");

    MYSQL_RES  *res;
    res = mysql_store_result(conn);
    mysql_free_result(res);
    printf("    pass! during write prepare, select should be sent to slave.\n");
//*****case1 end
//*****case2:basic write prepare executed successfully
	execWStmtAndCmp(stmt, 1, 1);
    printf("    pass! execute write prepare success.\n");

//*****case2 end

//*****case3:during read tx, cant execute write prepare, after tx over, both r/w-prepare work fine
    printf("    *****during read tx, cant execute write prepare, after tx over, both r/w-prepare work fine*****\n");
    char sql[50];
    strcpy(sql, "truncate ");
    strcat(sql, TEST_TABLE);
    myquery(conn, sql);
    MYSQL_STMT *rstmt = create_stmt_and_prepare(conn, "hello ", "stmt");
    execStmtAndCmp(rstmt,conn, "hello stmt");
    printf("    start transaction read only\n");
    myquery(conn, "start transaction read only");
    execWStmtAndCmp(stmt, 3, 2);
    myquery(conn, "commit");
    printf("    commit trx\n");
    execWStmtAndCmp(stmt, 1, 2);
    execStmtAndCmp(rstmt,conn, "hello stmt");

    close_stmt(rstmt);
//*****case3 end
//*****case4:close the same stmt twice, the second got err, and uproxy process this err correctly
    close_stmt(stmt);
    printf("    pass! close_stmt.\n");
    //todo, repeat-call always run into crash, how to avoid?
	//this repeat-call is not a bug, uproxy once crashed due to repeat call
//	try{
//        close_stmt(stmt);
//    }catch(...){
//        printf("Err:double free or corruption (fasttop) xxxxxxxxx");
//    }

//*****case4 end
//*****case5:after master prepare close, select should be sent to slave
    myquery(conn, slave_sql);
    printf("    pass! after write ps close, select should be sent to slave.\n");

    res = mysql_store_result(conn);
    mysql_free_result(res);
//*****case5 end
}

