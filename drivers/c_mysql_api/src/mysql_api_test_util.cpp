//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================

#include "mysql_api_test_util.h"

MYSQL* getConn(){
	printf("    create new conn! \n");
	MYSQL* conn = mysql_init(NULL);
    if(IS_DEBUG){
		printf("    host:%s, use:%s, passwd:%s, port:%d \n", Host_Single_MySQL, TEST_USER, TEST_USER_PASSWD, MYSQL_PORT);
        mysql_real_connect(conn, Host_Single_MySQL, TEST_USER, TEST_USER_PASSWD, "", MYSQL_PORT,NULL, CLIENT_DEPRECATE_EOF);
    }else{
		printf("    host:%s, use:%s, passwd:%s, port:%d \n", Host_Test, TEST_USER, TEST_USER_PASSWD, TEST_PORT);
        mysql_real_connect(conn, Host_Test, TEST_USER, TEST_USER_PASSWD, "", TEST_PORT,NULL, CLIENT_DEPRECATE_EOF);
	}
    if (conn == NULL) {
        printf("Error connecting to database: %s\n", mysql_error(conn));
        exit(1);
    }

    if(IS_DEBUG){
        if(mysql_query(conn, "drop database if exists schema1")){
		printf("'drop database if exists schema1' err: %s\n", mysql_error(conn));
		exit(1);
	    }else{
		    printf("    'drop database if exists schema1'\n");
	    }

	    if(mysql_query(conn, "create database schema1")){
		    printf("'create database schema1' err: %s\n", mysql_error(conn));
		    exit(1);
	    }else{
		    printf("    'create database schema1'\n");
	    }
    }


	if(mysql_query(conn, "use schema1")){
		printf("'use schema1' err: %s\n", mysql_error(conn));
		exit(1);
	}else{
		printf("    'use schema1'\n");
	}

    return conn;
}

void createTable(MYSQL* mysql){
	  if (mysql_query(mysql, DROP_SAMPLE_TABLE))
	  {
	    fprintf(stderr, " DROP TABLE failed\n");
	    fprintf(stderr, " %s\n", mysql_error(mysql));
	    exit(1);
	  }

	  if (mysql_query(mysql, CREATE_SAMPLE_TABLE))
	  {
	    fprintf(stderr, " CREATE TABLE failed\n");
	    fprintf(stderr, " %s\n", mysql_error(mysql));
	    exit(1);
	  }
 }

void createAndFillTable(MYSQL* mysql){
	char sql[100];
    strcpy(sql, "drop table if exists test_table");
//    printf("query: %s\n", sql);
    myquery(mysql_query(mysql, sql), mysql);

    strcpy(sql, "create table test_table(id int)");
//    printf("query: %s\n", sql);
    myquery(mysql_query(mysql, sql), mysql);

    strcpy(sql, "insert into test_table values(1),(2),(3)");
//    printf("query: %s\n", sql);
    myquery(mysql_query(mysql, sql), mysql);
}

int doPrintResult(MYSQL* mysql, MYSQL_RES  *res){
    MYSQL_ROW  row;
    MYSQL_FIELD  *fields;
    unsigned int  num_fields;
    unsigned int  i;
    MYSQL_FIELD *field;
    unsigned long *lengths;

    num_fields = mysql_num_fields(res);             //获取查询结果中，字段的个数
    fields = mysql_fetch_fields(res);
    //获取查询结果中，各个字段的名字
    if(IS_DEBUG){
		for(i = 0; i < num_fields;i++)
		{
			//mysql_fetch_field_direct
			field = mysql_fetch_field_direct(res, i);
			printf("result field %u:  %s\n",i,field->name);
		}
    }

    //print result lines
    unsigned long num_rows = mysql_num_rows(res);
    if(IS_DEBUG){ printf("Number of rows %lu\n", num_rows);}
    if(num_rows>1024)
    {
        printf("MAXIPLIST is not enough！\n");
        return num_rows;
    }

    while(row=mysql_fetch_row(res))
    {
        lengths = mysql_fetch_lengths(res);
        if(IS_DEBUG){
			for(i = 0; i < num_fields;i++){
				printf("field %d: %-20s, length:%lu",i,row[i], lengths[i]);
			}
        }
        if(IS_DEBUG){ printf("\n");}
    }
    return num_rows;
}

int printResult(MYSQL* mysql){
    MYSQL_RES  *res;

    res=mysql_store_result(mysql);
	int status = doPrintResult(mysql, res);
    mysql_free_result(res);
    return status;
}


void doQueryWithExpectInt(MYSQL* conn, char* sql, int expect){
	MYSQL_ROW  row;

    myquery(mysql_query(conn, sql),conn);
    MYSQL_RES  *res=mysql_store_result(conn);
	if(row=mysql_fetch_row(res)){
        char *field = row[0];

        if(expect == -9999){
            if(IS_DEBUG) printf("'%s' expect:(null), get:%s,", sql, field);
            if(field==NULL){
            		if(IS_DEBUG) printf("pass!\n");
	        }else{
				printf("fail!\n");
				exit(1);
	        }
	        return;
        }

        char expect_str[30];
        sprintf(expect_str, "%d", expect);

        if(IS_DEBUG) printf("'%s' expect:%s, get:%s\n", sql, expect_str, field);

        if(strcmp(field, expect_str)==0){
        	    if(IS_DEBUG) printf("pass!\n");
        }else{
			printf("fail!\n");
			exit(1);
        }
	}
	mysql_free_result(res);
}

void printMultiRes(MYSQL* conn, int status){
	printf("    print multi resultsets:\n");
	/* process each statement result */
	do {
		/* did current statement return data? */
		MYSQL_RES  *result = mysql_store_result(conn);
		if (result)
		{
		    /* yes; process rows and free the result set */
		    doPrintResult(conn, result);
		    mysql_free_result(result);
		}
		else          /* no result set or error */
		{
		    if (mysql_field_count(conn) == 0)
		    {
		      printf("    %lld rows affected\n",
		            mysql_affected_rows(conn));
		    }
		    else  /* some error occurred */
		    {
		      printf("    Could not retrieve result set\n");
		      break;
		    }
		}

		if(mysql_more_results(conn)){
			printf("    More results exist\n");
		}
		/* more results? -1 = no, >0 = error, 0 = yes (keep looping) */
		if ((status = mysql_next_result(conn)) > 0)
		    printf("    Could not execute statement\n");
	} while (status == 0);
}
