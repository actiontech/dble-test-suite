//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_real_connect(MYSQL* conn){
    printf("==>mysql_real_connect && mysql_character_set_name && mysql_data_seek && mysql_info && mysql_dump_debug_info test suites \n" );

//	case1: default_db=null, port=0
	MYSQL* test_conn = mysql_init(NULL);
	mysql_options(test_conn,MYSQL_OPT_COMPRESS,"0");
	mysql_options(test_conn,MYSQL_READ_DEFAULT_GROUP,"odbc");
	mysql_options(test_conn,MYSQL_INIT_COMMAND,"SET autocommit=0");
	if(IS_DEBUG){
        mysql_real_connect(test_conn, HOST_MASTER, TEST_USER, TEST_USER_PASSWD, NULL, 0,NULL, CLIENT_DEPRECATE_EOF|CLIENT_MULTI_STATEMENTS);
	}else{
        mysql_real_connect(test_conn, HOST_DBLE, TEST_USER, TEST_USER_PASSWD, NULL, DBLE_PORT,NULL, CLIENT_DEPRECATE_EOF|CLIENT_MULTI_STATEMENTS);
	}

    if (test_conn == NULL) {
        printf("Error connecting to database: %s\n", mysql_error(test_conn));
        exit(1);
    }else{
        printf("connect success");
    }
    printf("    *****pass! mysql_real_connect create conn with no default db allow multi-statements success*****\n");

    if(mysql_query(test_conn, "select @@autocommit")){
        fprintf(stderr, "'select @@autocommit' Error:%s\n", mysql_error(test_conn));
        exit(1);
    }else{
        printResult(test_conn);
        printf("    pass! single sql success\n");
    }

    if(mysql_query(test_conn, "show tables")){
        fprintf(stderr, "    pass! no default db, 'show tables' get Error:%s, Error no: %d\n", mysql_error(test_conn), mysql_errno(test_conn));
    }else{
        printResult(test_conn);
        printf("    *****no default db, show tables success, but expect err*****\n");
        exit(1);
    }

	//case: multi query, and multi resultsets
	/* execute multiple statements */
	int status = mysql_query(test_conn,
	                     "use schema1; \
	                      DROP TABLE IF EXISTS sharding_4_t1;\
	                      CREATE TABLE sharding_4_t1(id INT);\
	                      INSERT INTO sharding_4_t1 VALUES(10);\
	                      INSERT INTO sharding_4_t1 VALUES(20);\
	                      INSERT INTO sharding_4_t1 VALUES(30);\
	                      SELECT * FROM sharding_4_t1;");
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
			exit(1);
		}
	} while (status == 0);

	mysql_autocommit(test_conn, 1);

	const char *charset = mysql_character_set_name(test_conn);
	fprintf(stdout, "    *****pass! mysql_character_set_name, character set: %s*****\n", charset);

	//mysql_data_seek
	myquery(test_conn, "select * from sharding_4_t1");
	MYSQL_RES  *result = mysql_store_result(test_conn);
	if (result)
	{
	    mysql_data_seek(result, 2);
	    printf("    *****pass! mysql_data_seek*****\n");

		//mysql_fetch_field
		MYSQL_FIELD *field;
		while((field = mysql_fetch_field(result)))
		{
		    if(IS_DEBUG) printf("field name %s\n", field->name);
		}
	    mysql_free_result(result);
	}else{
		printf("expect select has rows, but result is null\n");
		exit(1);
	}

	//mysql_info
	printf("    *****pass! mysql_info*****\n");
	myquery(test_conn, "Insert into sharding_4_t1 values(111),(222),(333)");
	const char* info = mysql_info(test_conn);
	printf("        mysql_info: %s\n", info);

	//mysql_dump_debug_info, don't support at present. reference to http://10.186.18.25/universe/uproxy/issues/241
//	if(mysql_dump_debug_info(test_conn)){
//		fprintf(stderr, "Error: %s\n", mysql_error(test_conn));
//		exit(1);
//	}else{
//		printf("    *****pass! mysql_dump_debug_info*****\n");
//	}

	mysql_close(test_conn);
}
