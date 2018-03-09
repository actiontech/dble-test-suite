#include "c_mysql_api.h"

void case_mysql_info(MYSQL* mysql) {
	printf("==>mysql_info test suits\n");

	myquery(mysql_query(mysql, "drop table if exists mytest_test1"), mysql);
	myquery(mysql_query(mysql, "create table global_test1(id int, data varchar(100))"), mysql);
	myquery(mysql_query(mysql, "insert into global_test1 values (1,'aaa'),(2,'bbb'),(3,'ccc')"), mysql);

	const char *mysql_info_value = mysql_info(mysql);
	printf("   Pass! mysql_info.mysql_info: %s\n", mysql_info_value);

}