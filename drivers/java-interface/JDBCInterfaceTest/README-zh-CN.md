## 测试执行说明

- 测试环境:linux Centos7

- 测试准备：

   1.部署好自动化测试环境

   2.安装数据库中间件

- 测试步骤：

   1.进入behave 容器

      docker exec -it behave bash

   2.cd /init_assets/,找到 自动化测试项目

   3.将项目JDBCInterfaceTest 打包成可运行的java jar包放置 dble-test-suite/drivers/java-interface/JDBCInterfaceTest/目录，可借助工具，以eclipse举例：

      1) eclipse打开JDBCInterfaceTest项目 -选中该项目-右键-Export
      2）在弹出框 选择Java-Runnable JAR file- next
      3) 在Launch configuration 项选择Main-JDBCInterfaceTest(如果没有该选项，请先执行一遍 main.java)
      4) 在Export destination 选择保存路径，点击Finish
  
      注：在eclipse打开项目时，可能会提示有external jar找不到，按照以下方式重新添加jar包即可：
      
      选中该项目-右键-Build Path-Configure build path- Add External JARs-重新添加 ini4j-0.5.4.jar、jsch-0.1.54.jar、mysql-connector-java-5.1.31.jar
      
   4.执行 java -jar ${jar包名} 
