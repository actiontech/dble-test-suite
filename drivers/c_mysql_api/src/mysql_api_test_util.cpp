//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================

#include "mysql_api_test_util.h"

MYSQL* createConn(){
	printf("    create new conn! \n");
	MYSQL* conn = mysql_init(NULL);
    if(IS_DEBUG){
		printf("    host:%s, use:%s, passwd:%s, port:%d \n", HOST_MASTER, TEST_USER, TEST_USER_PASSWD, MYSQL_PORT);
        mysql_real_connect(conn, HOST_MASTER, TEST_USER, TEST_USER_PASSWD, "", MYSQL_PORT,NULL, CLIENT_DEPRECATE_EOF);
    }else{
		printf("    host:%s, use:%s, passwd:%s, port:%d \n", HOST_DBLE, TEST_USER, TEST_USER_PASSWD, DBLE_PORT);
        mysql_real_connect(conn, HOST_DBLE, TEST_USER, TEST_USER_PASSWD, "", DBLE_PORT,NULL, CLIENT_DEPRECATE_EOF);
	}
    if (conn == NULL) {
        printf("Error connecting to database: %s\n", mysql_error(conn));
        exit(1);
    }
    return conn;
}

MYSQL* getConn(){
	MYSQL* conn = createConn();
	char sql[50] = "use schema1";
	myquery(conn, sql);
    return conn;
}

void createTable(MYSQL* mysql){
	myquery(mysql, DROP_SAMPLE_TABLE);
	myquery(mysql, CREATE_SAMPLE_TABLE);
 }

void createAndFillTable(MYSQL* mysql){
	char sql[100];
    strcpy(sql, "drop table if exists sharding_4_t1");

    myquery(mysql, sql);

    strcpy(sql, "create table sharding_4_t1(id int)");

    myquery(mysql, sql);

    strcpy(sql, "insert into sharding_4_t1 values(1),(2),(3)");

    myquery(mysql, sql);
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

    myquery(conn, sql);
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
