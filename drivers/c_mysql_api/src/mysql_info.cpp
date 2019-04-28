#include "c_mysql_api.h"

void case_mysql_info(MYSQL* mysql) {
	printf("==>mysql_info test suits\n");

	myquery(mysql, "drop table if exists sharding_4_t1");
	myquery(mysql, "create table sharding_4_t1(id int, data varchar(100))");
	myquery(mysql, "insert into sharding_4_t1 values (1,'aaa'),(2,'bbb'),(3,'ccc')");

	const char *mysql_info_value = mysql_info(mysql);
	printf("   Pass! mysql_info.mysql_info: %s\n", mysql_info_value);

}