/*
 * env.h
 *
 *  Created on: 2017年10月16日
 *      Author: apple
 */

#ifndef MYSQL_API_TEST_UTIL_H_
#define MYSQL_API_TEST_UTIL_H_

#include<mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <iostream>
using namespace std;

#include "extract_info_from_config.h"

/* Print the error message */
#define DIE_UNLESS(expr)                                        \
((void) ((expr) ? 0 : (die(__FILE__, __LINE__, #expr), 0)))

static void die(const char *file, int line, const char *expr)
{
 fflush(stdout);
 fprintf(stderr, "%s:%d: check failed: '%s'\n", file, line, expr);
 fflush(stderr);
 exit(1);
}

static void print_error(MYSQL *l_mysql)
{
   if (l_mysql && mysql_errno(l_mysql))
   {
     if (l_mysql->server_version)
     fprintf(stdout, "\n [MySQL-%s]", l_mysql->server_version);
     else
     fprintf(stdout, "\n [MySQL]");
     fprintf(stdout, "[%d] %s\n", mysql_errno(l_mysql), mysql_error(l_mysql));
   }
}
MYSQL* createConn();
static void myquery( MYSQL* conn, const char* sql){
	if(IS_DEBUG) printf("sql:%s\n",sql);
	int r= (mysql_query(conn, sql));
	if (r) {
		print_error(conn);
	}
	DIE_UNLESS(r == 0);
}

void doQueryWithExpectInt(MYSQL* conn, char* sql, int expect);
MYSQL* getConn();
int printResult(MYSQL* mysql);
int doPrintResult(MYSQL* mysql, MYSQL_RES  *res);
void createAndFillTable(MYSQL* mysql);
void printMultiRes(MYSQL* conn, int status);
void createTable(MYSQL* mysql);

#endif /* MYSQL_API_TEST_UTIL_H_ */
