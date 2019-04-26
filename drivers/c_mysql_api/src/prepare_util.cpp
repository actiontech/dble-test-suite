//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "prepare_util.h"

short         small_data=0;
int           int_data=0;
char          str_data[STRING_SIZE]={};
unsigned long str_length=0;
my_bool       is_null;
MYSQL_BIND    wbind[3];
int param_count = 0;

MYSQL_STMT * create_stmt_and_prepare(MYSQL* conn, char* param1, char* param2){
    MYSQL_STMT *stmt = mysql_stmt_init(conn);
    if (stmt == NULL) {
        printf(" init stmt err!\n");
        exit(1);
    }

    char sql[] = "select concat(?, ?)";

    if (mysql_stmt_prepare(stmt, sql, strlen(sql)) != 0) {
        printf(" prepare stmt err! %s\n", mysql_error(conn));
        exit(1);
    }

    MYSQL_BIND bind[2];
    memset(bind, 0, sizeof(bind));
    bind[0].buffer_type = MYSQL_TYPE_STRING;
    bind[0].buffer = param1;;
    bind[0].buffer_length = strlen(param1);
    bind[1].buffer_type = MYSQL_TYPE_STRING;
    bind[1].buffer = param2;
    bind[1].buffer_length = strlen(param2);

    mysql_stmt_bind_param(stmt, bind);
    printf("    create new ps success!\n");
    return stmt;
 }

void execStmtAndCmp(MYSQL_STMT *stmt, MYSQL *conn, char* expect){
    const size_t OUTSIZE = 64;
    char out_buf[OUTSIZE];

    MYSQL_BIND result[1];
    memset(result, 0, sizeof(result));
    result[0].buffer_type = MYSQL_TYPE_STRING;
    result[0].buffer = out_buf;
    result[0].buffer_length = OUTSIZE;

    unsigned long type = CURSOR_TYPE_READ_ONLY;
    mysql_stmt_attr_set(stmt, STMT_ATTR_CURSOR_TYPE, (void*)&type);

    mysql_stmt_execute(stmt);
    mysql_stmt_bind_result(stmt, result);
    mysql_stmt_store_result(stmt);

    if (mysql_stmt_fetch(stmt) != 0) {
        printf(" fetch stmt result err! %s\n", mysql_error(conn));
        exit(1);
    }else{
        if (IS_DEBUG) printf("++++++++++++ fetch result: +++++++++++++\n");
        do{
        		if (IS_DEBUG) printf("val = %s\n", out_buf);
        }while (mysql_stmt_fetch(stmt) == 0);
    }

    if(strcmp(out_buf, expect)){
        printf(" expect '%s', but get '%s'\n", expect, out_buf);
        exit(1);
    }else{
        printf("    pass! execute ps get the same result as expect.\n");
    }
}

void close_stmt(MYSQL_STMT *stmt){
    if (mysql_stmt_close(stmt))
      {
        fprintf(stderr, " failed while closing the statement\n");
        fprintf(stderr, " %s\n", mysql_stmt_error(stmt));
        exit(1);
      }
}

  /* Prepare an INSERT query with 3 parameters */
  /* (the TIMESTAMP column is not named; the server */
  /*  sets it to the current date and time) */
MYSQL_STMT  *create_wstmt_and_prepare(MYSQL *conn){
    /* INTEGER PARAM */
    /* This is a number type, so there is no need
     to specify buffer_length */
    wbind[0].buffer_type= MYSQL_TYPE_LONG;
    wbind[0].buffer= (char *)&int_data;
    wbind[0].is_null= 0;
    wbind[0].length= 0;

    /* STRING PARAM */
    wbind[1].buffer_type= MYSQL_TYPE_STRING;
    wbind[1].buffer= (char *)str_data;
    wbind[1].buffer_length= STRING_SIZE;
    wbind[1].is_null= 0;
    wbind[1].length= &str_length;

    /* SMALLINT PARAM */
    wbind[2].buffer_type= MYSQL_TYPE_SHORT;
    wbind[2].buffer= (char *)&small_data;
    wbind[2].is_null= &is_null;
    wbind[2].length= 0;

    MYSQL_STMT  *stmt = mysql_stmt_init(conn);
    if (!stmt)
    {
        fprintf(stderr, " mysql_stmt_init(), out of memory\n");
        exit(1);
    }
    if (mysql_stmt_prepare(stmt, INSERT_SAMPLE, strlen(INSERT_SAMPLE)))
    {
        fprintf(stderr, " mysql_stmt_prepare(), INSERT failed\n");
        fprintf(stderr, " %s\n", mysql_stmt_error(stmt));
        exit(1);
    }
    fprintf(stdout, "    prepare INSERT statement successful\n");

    param_count= mysql_stmt_param_count(stmt);
    fprintf(stdout, "    total parameters in INSERT: %d\n", param_count);

    if (param_count != 3) /* validate parameter count */
    {
        fprintf(stderr, " invalid parameter count returned by MySQL\n");
        exit(1);
    }

    /* Bind the buffers */
    if (mysql_stmt_bind_param(stmt, wbind))
    {
        fprintf(stderr, " mysql_stmt_bind_param() failed\n");
        fprintf(stderr, " %s\n", mysql_stmt_error(stmt));
        exit(1);
    }

    return stmt;
}

void execWStmtAndCmp(MYSQL_STMT *stmt, int expect, int type){
    switch(type){
        case 1:{
                if(IS_DEBUG) fprintf(stdout, "    write prepare type: %d\n", type);
                /* Specify the data values for the first row */
                int_data= 10;             /* integer */
                strncpy(str_data, "MySQL", STRING_SIZE); /* string  */
                str_length= strlen(str_data);
                is_null= 1;
                break;
            }
        case 2:{
                if(IS_DEBUG) fprintf(stdout, " write prepare type: %d\n", type);
              /* Specify data values for second row,
                 then re-execute the statement */
                int_data= 1000;
                strncpy(str_data, "The most popular Open Source database",STRING_SIZE);
                str_length= strlen(str_data);
                small_data= 1000;         /* smallint */
                is_null= 0;               /* reset */
                break;
            }
    }

    if (mysql_stmt_execute(stmt))
    {
        if(expect != 3){//3 means the err is as expected: Cannot execute statement in a READ ONLY transaction.
			fprintf(stderr, "mysql_stmt_execute(), failed. err:%s \n", mysql_stmt_error(stmt));
            exit(1);
        }else{
			fprintf(stderr, "    pass! mysql_stmt_execute failed as expect. err:%s \n", mysql_stmt_error(stmt));
        }
        return ;
    }

    /* Get the number of affected rows */
    int affected_rows= mysql_stmt_affected_rows(stmt);
    if(IS_DEBUG) fprintf(stdout, "    total affected rows(insert 1): %lu\n",
                  (unsigned long) affected_rows);

    if (affected_rows != expect) /* validate affected rows */
    {
        fprintf(stderr, " invalid affected rows by MySQL\n");
        exit(1);
    }

	printf("    pass! write ps execute get the same result as expect. \n");
}
