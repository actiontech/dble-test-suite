/*
 * prepare_test.h
 *
 *  Created on: 2017年10月16日
 *      Author: apple
 */

#ifndef PREPARE_UTIL_H_
#define PREPARE_UTIL_H_
#include <mysql.h>
#include <stdio.h>
#include <string.h>
#include "mysql_api_test_util.h"

//write prepare test related vars
#define STRING_SIZE 50
#define INSERT_SAMPLE "INSERT INTO \
                       sharding_4_t1(id,col2,col3) \
                       VALUES(?,?,?)"

extern short         small_data;
extern int           int_data;
extern char          str_data[STRING_SIZE];
extern unsigned long str_length;
extern my_bool       is_null;
extern MYSQL_BIND    wbind[3];
extern int           param_count;

//#define slave_sql "select 1 /*uproxy_dest_expect:S*/"
//end write prepare test related vars

MYSQL_STMT * create_stmt_and_prepare(MYSQL* conn, char* param1);
void execStmtAndCmp(MYSQL_STMT *stmt, MYSQL *conn, char* expect);
void close_stmt(MYSQL_STMT *stmt);
MYSQL_STMT  *create_wstmt_and_prepare(MYSQL *conn);
void execWStmtAndCmp(MYSQL_STMT *stmt, int expect, int type);


void wPrepareTest();
void rPrepareTest();
#endif /* PREPARE_UTIL_H_ */
