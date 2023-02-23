//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"

void case_mysql_set_character_set(MYSQL* mysql){
	printf("==>mysql_set_character_set && mysql_get_character_set_info test suites\n");

	if (mysql_set_character_set(mysql, "utf8")){
		printf("mysql_set_character_set failed \n");
		exit(1);
	}
	else{
		printf("    pass! mysql_set_character_set set charset utf8 .\n");
	    MY_CHARSET_INFO cs;
	    mysql_get_character_set_info(mysql, &cs);
	    printf("    pass! mysql_get_character_set_info character set name: %s\n", cs.name);
	    if(IS_DEBUG){
			printf("    character set information:\n");
			printf("    character set+collation number: %d\n", cs.number);
			printf("    collation name: %s\n", cs.csname);
			printf("    comment: %s\n", cs.comment);
			printf("    directory: %s\n", cs.dir);
			printf("    multi byte character min. length: %d\n", cs.mbminlen);
			printf("    multi byte character max. length: %d\n", cs.mbmaxlen);
	    }
	}
}
