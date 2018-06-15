//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include<mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <iostream>
using namespace std;

int IS_DEBUG=0;
char Host_Master[50] = "172.100.9.5";
char Host_Uproxy[50] = "172.100.9.1";
char TEST_USER[100]="test";
char TEST_USER_PASSWD[100]="111111";
char TEST_DB[50]="mytest";
unsigned int PORT=3306;
unsigned int MPORT=8066;

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
    for(i = 0; i < num_fields;i++)
    {
        //mysql_fetch_field_direct
        field = mysql_fetch_field_direct(res, i);
        printf("result field %u:  %s\n",i,field->name);
    }

    //print result lines
    unsigned long num_rows = mysql_num_rows(res);
    printf("Number of rows %lu\n", num_rows);
    if(num_rows>1024)
    {
        printf("MAXIPLIST is not enough！\n");
        return num_rows;
    }

    while(row=mysql_fetch_row(res))
    {
        lengths = mysql_fetch_lengths(res);
        for(i = 0; i < num_fields;i++){
            printf("field %d: %-20s, length:%lu",i,row[i], lengths[i]);
        }
        printf("\n");
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

void case_mysql_real_connect(const char* sqls){
    printf("==>c_api_quick_test \n");

    MYSQL* test_conn = mysql_init(NULL);
    mysql_options(test_conn,MYSQL_OPT_COMPRESS,"0");
    mysql_options(test_conn,MYSQL_READ_DEFAULT_GROUP,"odbc");
    mysql_options(test_conn,MYSQL_INIT_COMMAND,"SET autocommit=1");
    if(IS_DEBUG){
        mysql_real_connect(test_conn, Host_Master, TEST_USER, TEST_USER_PASSWD, TEST_DB, PORT,NULL, CLIENT_DEPRECATE_EOF|CLIENT_MULTI_STATEMENTS);
    }else{
        mysql_real_connect(test_conn, Host_Uproxy, TEST_USER, TEST_USER_PASSWD, TEST_DB, MPORT,NULL, CLIENT_DEPRECATE_EOF|CLIENT_MULTI_STATEMENTS);
    }

    if (test_conn == NULL) {
        printf("Error connecting to database: %s\n", mysql_error(test_conn));
        exit(1);
    }else{

    }
    printf("    *****pass! mysql_real_connect create conn with no default db allow multi-statements success*****\n");

    //case: multi query, and multi resultsets
    /* execute multiple statements */
    int status = mysql_query(test_conn,sqls);
    if (status)
    {
      printf("execute multi statement(s) Err, %s \n", mysql_error(test_conn));
      mysql_close(test_conn);
      exit(1);
    }else{
        printf("    pass! multi sqls success\n");
    }

    printf("        print multi resultsets:\n");
    /* process each statement result */
    do {
        /* did current statement return data? */
        MYSQL_RES  *result = mysql_store_result(test_conn);
        if (result)
        {
            /* yes; process rows and free the result set */
            doPrintResult(test_conn, result);
            mysql_free_result(result);
        }
        else          /* no result set or error */
        {
            if (mysql_field_count(test_conn) == 0)
            {
              printf("        %lld rows affected\n",
                    mysql_affected_rows(test_conn));
            }
            else  /* some error occurred */
            {
              printf("Could not retrieve result set\n");
              exit(1);
            }
        }

        if(mysql_more_results(test_conn)){
            printf("        More results exist\n");
        }
        /* more results? -1 = no, >0 = error, 0 = yes (keep looping) */
        if ((status = mysql_next_result(test_conn)) > 0){
            printf("Could not get next result\n");
            //exit(1);
        }
    } while (status == 0);

    mysql_close(test_conn);
}
int main(int argc, char *argv[]) {
    if (argc>1){
        IS_DEBUG = strcmp(argv[1],"debug")==0;
        printf("IS_DEBUG: %d, argc:%d, argv[1]:%s\n", IS_DEBUG, argc, argv[1]);
    }
    

    char sqls[] = "use mytest; \
                    DROP TABLE IF EXISTS test_table;\
                    CREATE TABLE test_table(id INT);\
                    begin; \
                    INSERT INTO test_table VALUES(10);\
                    INSERT INTO test_table VALUES(20);\
                    commit;";

    char sqls2[] = "lock tables test_table write; \
                    UPDATE test_table SET id=20 WHERE id=10;\
                    unlock tables; \
                    start transaction; \
                    INSERT INTO test_table VALUES(30);\
                    rollback";
    char sqls3[] = "SELECT * FROM test_table/* comment */; \
                    /*! select 1*/;\
                    /* line 1 \
                    line 2 */ ;\
                    --i am comment";

    case_mysql_real_connect(sqls);
    case_mysql_real_connect(sqls2);
    char sqls4[] = "select @@version_comment; \
                  select database();\
                  select user();\
                  select version();\
                  select @@session.auto_increment_increment;\
                  select @@session.tx_isolation;\
                  select last_insert_id() as `id`;\
                  select @@identity; \
                  select @@session.tx_read_only";
    case_mysql_real_connect(sqls4);

    char sqls5[] = "explain select 1; \
                  create table test_table t(id int);\
                  desc test_table;\
                  create view view_test_table as select * from test_table;\
                  drop view view_test_table;\
                  show databases;\
                  set @a='test';";
    case_mysql_real_connect(sqls5);
}
