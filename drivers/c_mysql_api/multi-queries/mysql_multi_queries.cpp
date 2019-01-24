//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : in C++, Ansi-style
//============================================================================
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <iostream>
using namespace std;

int IS_DEBUG=0;
char Host_Master[50] = "172.100.9.4";
char Host_Dble[50] = "172.100.9.1";
char TEST_USER[100]="test";
char TEST_USER_PASSWD[100]="111111";
char TEST_DB[50]="schema1";
unsigned int PORT=3306;
unsigned int DPORT=8066;

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
        mysql_real_connect(test_conn, Host_Dble, TEST_USER, TEST_USER_PASSWD, TEST_DB, DPORT,NULL, CLIENT_DEPRECATE_EOF|CLIENT_MULTI_STATEMENTS);
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
    printf("multi-sqls to execute: %s \n", sqls);
    if (status)
    {
      printf("execute multi statement(s) Err, %s \n", mysql_error(test_conn));
      mysql_close(test_conn);
      exit(1);
    }

    printf("        print multi resultsets:\n");
    /* process each statement result */
    int k = 0;
    do {
        printf("=====sql index %d result: =====\n", k);
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
        k++;
    } while (status == 0);

    mysql_close(test_conn);
}
int main(int argc, char *argv[]) {
    if (argc>1){
        IS_DEBUG = strcmp(argv[1],"debug")==0;
        printf("IS_DEBUG: %d, argc:%d, argv[1]:%s\n", IS_DEBUG, argc, argv[1]);
        printf("Usage:./c_mysql_api.o debug \n");
    }
    

    char sqls[] = "use schema1; \
                    DROP TABLE IF EXISTS aly_test;\
                    CREATE TABLE aly_test(id INT);\
                    begin; \
                    INSERT INTO aly_test VALUES(10);\
                    INSERT INTO aly_test VALUES(20);\
                    commit;\
                    select * from aly_test order by id";

/*lock tables read should be write, but not support at present
                    lock tables aly_test write; \
                    UPDATE aly_test SET id=20 WHERE id=10;\
                    unlock tables; \
                    */
    char sqls2[] = "start transaction; \
                    INSERT INTO aly_test VALUES(30);\
                    rollback;\
                    select * from aly_test order by id;";
    char sqls3[] = "SELECT * FROM aly_test/* comment */ order by id; \
                    /*! select 1*/;\
                    /* line 1 \
                    line 2 */ ;\
                    --i am comment";

    case_mysql_real_connect(sqls);

//different dble version will make the std_result compare fail, todo: find a way to resolve
//                  select version();\
    case_mysql_real_connect(sqls2);
    char sqls4[] = "select @@version_comment; \
                  select database();\
                  select user();\
                  select @@session.auto_increment_increment;\
                  select @@session.tx_isolation;\
                  select last_insert_id() as `id`;\
                  select @@identity; \
                  select @@session.tx_read_only";
    case_mysql_real_connect(sqls4);

    char sqls5[] = "desc aly_test;\
                  drop view if exists view_aly_test;\
                  create view view_aly_test as select * from aly_test;\
                  drop view if exists view_aly_test;\
                  show databases;\
                  set @a='test';";
    case_mysql_real_connect(sqls5);
}
