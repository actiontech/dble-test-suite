//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_use_result(MYSQL* mysql){
	printf("==>mysql_use_result && mysql_field_count && mysql_fetch_row && mysql_fetch_field_direct && mysql_free_result test suites\n");

	createAndFillTable(mysql);

    MYSQL_ROW  row;
    MYSQL_FIELD  *fields;
    unsigned int  i;
    MYSQL_FIELD *field;

	myquery(mysql, "SELECT * FROM test_table/*master*/");
	MYSQL_RES  *result = mysql_use_result(mysql);
	printf("    pass! mysql_use_result \n");
	unsigned int num_fields = mysql_field_count(mysql);
	printf("    pass! mysql_field_count:%u \n", num_fields);

	printf("    pass! mysql_fetch_row:\n");
	while((row = mysql_fetch_row(result)) != NULL)
	   {
	    for(i = 0; i < num_fields; i++)
	      {
	       field = mysql_fetch_field_direct(result, i);
	       printf("    %s: %s, ", field->name, row[i]);
	      }
	   printf("\n");
	}
	mysql_free_result(result);
	printf("    pass! mysql_free_result:\n");
}
