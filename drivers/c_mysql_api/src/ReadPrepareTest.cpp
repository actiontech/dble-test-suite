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

    const char* para1="hello ";
    const char* para2="stmt";
    const char* para3="stmt2";
    const char* para4="stmt3";
    const char* para12="hello stmt";
    const char* para13="hello stmt2";
    const char* para14="hello stmt3";

    createTable(conn);

    MYSQL_STMT *stmt = create_stmt_and_prepare(conn, const_cast<char*>(para1), const_cast<char*>(para2));
    unsigned long type = CURSOR_TYPE_READ_ONLY;
    mysql_stmt_attr_set(stmt, STMT_ATTR_CURSOR_TYPE, (void*)&type);

//******case1:read prepare execute correctly
	execStmtAndCmp(stmt,conn, const_cast<char*>(para12));
//******case1 end

//******case2:during read prepare, sqls that should be sent to master should still be sent to master
	myquery(conn, "insert into test_table(id,col2,col3) values(1,'abc',2)");
    printf("    pass! before read ps deallocate, queries should be sent to master should still be sent to master.\n");
//******case2 end

//*****case3:two read prepare should not affact each other
    printf("    *****two read ps should not affact each other*****\n");
	execStmtAndCmp(stmt,conn, const_cast<char*>(para12));

	MYSQL_STMT *stmt2 = create_stmt_and_prepare(conn, const_cast<char*>(para1), const_cast<char*>(para3));

	execStmtAndCmp(stmt2, conn, const_cast<char*>(para13));

	/* Close the statement */
	close_stmt(stmt2);
	printf("    close one ps.\n");

	//this is the point
	execStmtAndCmp(stmt,conn, const_cast<char*>(para12));
//******case3 end
//*****case4:read prepare should correctly change from one slave to master if needed
    printf("    *****read ps should correctly change from one slave to master if needed*****\n");
    printf("    start transaction.\n");
	myquery(conn, "start transaction;");

	execStmtAndCmp(stmt,conn, const_cast<char*>(para12));

    printf("    commit.\n");
	myquery(conn, "commit;");

	execStmtAndCmp(stmt,conn, const_cast<char*>(para12));
//*****case4 end

/* dble do not support the stmt "start transaction read only"
//*****case5 diffenent ps on diffenent conns will not affected by each other.
    printf("    *****diffenent ps on diffenent conns will not affected by each other*****\n");
	//case5-step1
	myquery(conn, "start transaction read only;");

	//case5-step2
	MYSQL *conn2 = getConn();

    MYSQL_STMT *stmt3 = create_stmt_and_prepare(conn2, const_cast<char*>(para1), const_cast<char*>(para4));

	//case5-step3
	MYSQL *conn3 = getConn();

	myquery(conn3, "start transaction read only;");

	//case5-step4
	myquery(conn, "commit;");

	//case5-step5
	execStmtAndCmp(stmt3,conn2, const_cast<char*>(para14));
	execStmtAndCmp(stmt,conn, const_cast<char*>(para12));
	execStmtAndCmp(stmt3,conn2, const_cast<char*>(para14));
	execStmtAndCmp(stmt,conn, const_cast<char*>(para12));

	//case5-step6
	MYSQL *conn4 = getConn();
	myquery(conn4, "start transaction read only;");

	//case5-step7
	myquery(conn3, "commit;");
	mysql_close(conn3);

	//case5-step8
	close_stmt(stmt3);
	execStmtAndCmp(stmt,conn, const_cast<char*>(para12));

	//clear
	mysql_close(conn2);
	mysql_close(conn4);
//*****case5 end
*/

	close_stmt(stmt);
	mysql_close(conn);
}

//test when read preapre statements will get multi-results
void ps_multi_test(){
    printf("    *****when read preapre statements will get multi-results*****\n");

	MYSQL* con = getConn();

	myquery(con, "drop procedure if exists mytest.sp;");

	myquery(con,
			"create procedure sp()"
			"begin "
		    "    select 1,2;"
		    "    select 3,4;"
			"end"
	);

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
