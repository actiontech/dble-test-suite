#step1:编译drivers/c_mysql_api/c_mysql_api.c文件, 生成 c_mysql_api.o：
gcc c_mysql_api.c -o c_mysql_api.o -I/opt/mysql-5.7.13-linux-glibc2.5-x86_64/include -L/opt/mysql-5.7.13-linux-glibc2.5-x86_64/lib -lmysqlclient
#step2:运行
./c_mysql_api.o