//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_session_track_get_first(MYSQL* conn){
	printf("==>mysql_session_track_get_first && mysql_session_track_get_next test suites\n");
	createAndFillTable(conn);

	const char * stmt_str = "use schema1/*master*/";
//	printf("    Execute: %s\n", stmt_str);

	if (mysql_query(conn, stmt_str) != 0)
	{
	  fprintf(stderr, "Error %u: %s\n",
	           mysql_errno(conn), mysql_error(conn));
	  exit(1);
	}

	MYSQL_RES *result = mysql_store_result(conn);
	if (result) /* there is a result set to fetch */
	{
	  /* ... process rows here ... */
	  printf("fail, expect no result, but Number of rows returned: %lu\n",
	          (unsigned long) mysql_num_rows(result));
	  mysql_free_result(result);
	  exit(1);
	}
	else        /* there is no result set */
	{
	  if (mysql_field_count(conn) == 0)
	  {
	    printf("    query 'use dbname', Number of rows affected: %lu\n",
	            (unsigned long) mysql_affected_rows(conn));
	  }
	  else      /* an error occurred */
	  {
	    fprintf(stderr, "Error %u: %s\n",
	             mysql_errno(conn), mysql_error(conn));
	    exit(1);
	  }
	}

	/* extract any available session state-change information */
	printf("    call mysql_session_track_get_first:\n");
	enum enum_session_state_type enum_type;
	int type;
	for (type = int(SESSION_TRACK_BEGIN); type <= int(SESSION_TRACK_END); type++)
	{
	  const char *data;
	  size_t length;

	  enum_type=enum_session_state_type(type);
	  if (mysql_session_track_get_first(conn, enum_type, &data, &length) == 0)
	  {
//	    printf("Type=%d:\n", type);
	    printf("    mysql_session_track_get_first success, type:%d, returns: %*.*s\n",type,
	            (int) length, (int) length, data);

	    /* check for more data */
	    while (mysql_session_track_get_next(conn, enum_type, &data, &length) == 0)
	    {
	      printf("    mysql_session_track_get_next returns: %*.*s\n",
	              (int) length, (int) length, data);
	    }
	  }else{
		  printf("    mysql_session_track_get_first failed, type:%d \n", type);
//		  exit(1);
	  }
	}
}
