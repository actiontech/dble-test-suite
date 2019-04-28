//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_field_count(MYSQL* mysql){
	printf("==>mysql_field_count test suits\n");

	MYSQL_RES *result;
	unsigned int num_fields;
	unsigned int num_rows;

	myquery(mysql, "drop table if exists sharding_4_t1");

 // query succeeded, process any data returned by it
	result = mysql_store_result(mysql);
	if (result)  // there are rows
	{
		num_fields = mysql_num_fields(result);
		// retrieve rows, then call mysql_free_result(result)
	}
	else  // mysql_store_result() returned nothing; should it have?
	{
		if(mysql_field_count(mysql) == 0)
		{
			// query does not return data
			// (it was not a SELECT)
			num_rows = mysql_affected_rows(mysql);
			printf("    pass! drop table does not return data, mysql_field_count gets 0. \n");
		}
		else // mysql_store_result() should have returned data
		{
			fprintf(stderr, "Error: %s\n", mysql_error(mysql));
			exit(1);
		}
	}
}

