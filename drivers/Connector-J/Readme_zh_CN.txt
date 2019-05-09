linux Centos7 环境下运行 Java driver 代码说明：

1.配置java环境，安装jdk，具体步骤参考 文档 compose/install_jdk.sh

2.生成java jar包放置Connector-J/target/目录，可借助工具，以eclipse举例：
  1) 选中java项目-右键-Export
  2）在弹出框 选择Java-Runnable JAR file- next
  3) 在Launch configuration 项选择testJDBC-Connector-J(如果没有该选项，请先执行一遍 testJDBC.java)
  4) 在Export destination 选择保存路径，点击Finish

3.回到自动化项目目录，以拆分表的配置文件重启一遍dble，执行：
behave --stop -D dble_conf=sql_cover_sharding features/setup.feature

4.在Connector-J 目录，运行：bash run.sh {jar包名} [-c]
  注：1).加 -c 表示 生成的结果需要和标准sql文件做比对，
      2).覆盖的sql文件位置：dble/drivers/Connector-J/assets/sql/