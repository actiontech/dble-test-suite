//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "prepare_util.h"


void doRTest(){
    MYSQL *conn = getConn();

    createTable(conn);

    MYSQL_STMT *stmt = create_stmt_and_prepare(conn, "hello ", "stmt");
    unsigned long type = CURSOR_TYPE_READ_ONLY;
    mysql_stmt_attr_set(stmt, STMT_ATTR_CURSOR_TYPE, (void*)&type);

//******case1:read prepare execute correctly
	execStmtAndCmp(stmt,conn, "hello stmt");
//******case1 end

//******case2:during read prepare, sqls that should be sent to master should still be sent to master
	myquery(mysql_query(conn, "insert into test_table(col1,col2,col3) values(1,'abc',2) /*uproxy_dest_expect:M*/"),conn);
    printf("    pass! before read ps deallocate, queries should be sent to master should still be sent to master.\n");
//******case2 end

//*****case3:two read prepare should not affact each other
    printf("    *****two read ps should not affact each other*****\n");
	execStmtAndCmp(stmt,conn, "hello stmt");

	MYSQL_STMT *stmt2 = create_stmt_and_prepare(conn, "hello ", "stmt2");

	execStmtAndCmp(stmt2, conn, "hello stmt2");

	/* Close the statement */
	close_stmt(stmt2);
	printf("    close one ps.\n");

	//this is the point
	execStmtAndCmp(stmt,conn, "hello stmt");
//******case3 end
//*****case4:read prepare should correctly change from one slave to master if needed
    printf("    *****read ps should correctly change from one slave to master if needed*****\n");
    printf("    start transaction.\n");
	myquery(mysql_query(conn, "start transaction;"),conn);

	execStmtAndCmp(stmt,conn, "hello stmt");

    printf("    commit.\n");
	myquery(mysql_query(conn, "commit;"),conn);

	execStmtAndCmp(stmt,conn, "hello stmt");
//*****case4 end

//*****case5 diffenent ps on diffenent conns will not affected by each other.
    printf("    *****diffenent ps on diffenent conns will not affected by each other*****\n");
	//case5-step1
	myquery(mysql_query(conn, "start transaction read only;"),conn);

	//case5-step2
	MYSQL *conn2 = getConn();

    MYSQL_STMT *stmt3 = create_stmt_and_prepare(conn2, "hello ", "stmt3");

	//case5-step3
	MYSQL *conn3 = getConn();

	myquery(mysql_query(conn3, "start transaction read only;"),conn);

	//case5-step4
	myquery(mysql_query(conn, "commit;"),conn);

	//case5-step5
	execStmtAndCmp(stmt3,conn2, "hello stmt3");
	execStmtAndCmp(stmt,conn, "hello stmt");
	execStmtAndCmp(stmt3,conn2, "hello stmt3");
	execStmtAndCmp(stmt,conn, "hello stmt");

	//case5-step6
	MYSQL *conn4 = getConn();
	myquery(mysql_query(conn4, "start transaction read only;"),conn);

	//case5-step7
	myquery(mysql_query(conn3, "commit;"),conn);
	mysql_close(conn3);

	//case5-step8
	close_stmt(stmt3);
	execStmtAndCmp(stmt,conn, "hello stmt");

	//clear
	mysql_close(conn2);
	mysql_close(conn4);
//*****case5 end

	close_stmt(stmt);
	mysql_close(conn);
}

//test when read preapre statements will get multi-results
void ps_multi_test(){
    printf("    *****when read preapre statements will get multi-results*****\n");

	MYSQL* con = getConn();

	myquery(mysql_query(con, "drop procedure if exists schema1.sp;"),con);

	myquery(mysql_query(con,
			"create procedure sp()"
			"begin "
		    "    select 1,2;"
		    "    select 3,4;"
			"end"
	), con);

    MYSQL_STMT *stmt = mysql_stmt_init(con);
    if (stmt == NULL) {
    		printf("mysql_stmt_init failed.\n");
        exit(1);
    }
    char sql[30] = "call sp()";
    if (mysql_stmt_prepare(stmt, sql, strlen(sql)) != 0) {
        printf("mysql_stmt_prepare err! %s\n", mysql_error(con));
        exit(1);
    }

    int val, val2;
    size_t val_len,val_len2;

    MYSQL_BIND result[2];
    memset(result, 0, sizeof(result));
    result[0].buffer_type = MYSQL_TYPE_LONG;
    result[0].buffer = (char *)&val;
    result[0].length = &val_len;
    result[1].buffer_type = MYSQL_TYPE_LONG;
    result[1].buffer = (char *)&val2;
    result[1].length = &val_len2;
    if (mysql_stmt_execute(stmt) != 0) {
        printf("mysql_stmt_execute err! %s\n", mysql_error(con));
        exit(1);
    }

	int status = 0;
	int i = 0;
    printf("    +++ps multi result:+++\n");
    do {
        printf("    +++one of multi result:\n");
        if (mysql_stmt_result_metadata(stmt) == NULL) {
            // not a result set, e.g. the last OK packet
            break;
        }

        if (mysql_stmt_bind_result(stmt, result) != 0) {
            printf("mysql_stmt_bind_result err! %s\n", mysql_error(con));
            exit(1);
        }

        status = mysql_stmt_fetch(stmt);
        while (status == 0) {
            printf("    val = %d\n", val);
            printf("    val2 = %d\n", val2);
            status = mysql_stmt_fetch(stmt);
            if(status !=0){
                printf("    mysql_stmt_fetch err! %s, status: %d\n", mysql_error(con), status);
                break;
            }
        }

		printf("    mysql_stmt_fetch over\n");
        if(mysql_stmt_free_result(stmt)){
            printf("mysql_stmt_free_result err, %s\n", mysql_error(con));
			exit(1);
        }else{
			printf("    mysql_stmt_free_result over\n");
        }

        status = mysql_stmt_next_result(stmt);
        if(status !=0){
            printf("mysql_stmt_next_result err! %s\n", mysql_error(con));
            exit(1);
        }else{
			printf("    mysql_stmt_next_result over\n");
        }

    } while (status == 0);
}

void rPrepareTest() {
	printf("==>read prepare statement related test suites\n");

    doRTest();
    ps_multi_test();
}
