#Makefile中的mysql相关文件路径请相应修改
 INCLUDES := -I/opt/mysql/include
 LIBDIRS  :=-L/opt/mysql/lib

#编译
make

#可能遇到的问题及解决	
 - 1, g++找不到
 
   yum install gcc-c++
   
 - 2,libmysqlclient.so.20找不到
 
   /etc/ld.so.conf.d/mariadb-x86_64.conf，添加mysql lib的路径并执行 ldconfig
 
#不使用Makefile,手动编译（相关mysql文件夹路径自行替换）
g++ -g -o multiQuery.o -L/opt/mysql/lib -I/opt/mysql/include -lmysqlclient mysql_multi_queries.cpp

#运行
./multiQuery.o (链接dble)
./multiQuery.o debug (直连mysql)