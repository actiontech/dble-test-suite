# 1.2.3 基于c#的MySQL数据库驱动的sql覆盖测试

## sql覆盖的测试策略

- 抽出基础典型的sql到[driver专用sql case文件](./1.3 sql文件说明.md#), 按照连接中间件和直连的结果差异做分类并整理出标准结果，后续回归将运行的当次的回归结果与标准结果比对
- 整理中间件的管理命令到测试文件，检查driver是否支持
- 对[sql覆盖相关case文件](./1.3 sql文件说明.md), 可自主选择是否需要中间件和直连的执行结果差异，但不再整理标准结果

## 测试执行说明

- 测试环境:linux Centos7

- 测试准备：

   1.部署好自动化测试环境

   2.安装数据库中间件

   3.修改配置文件为所需要的配置，重新启动中间件。注：本文提供的标准sql结果比对日志是以 behave_dble/dble_conf/sql_cover_sharding_bk/目录下的配置文件跑的结果。

- 测试步骤：

   1.进入behave 容器

      docker exec -it behave bash

   2.cd /init_assets/,找到 自动化测试项目

   3.在源码所在目录 dble-test-suite/drivers/Connector-.Net/netdriver/，执行编译：

        csc -out:test.exe -r:MySql.Data.dll -r:YamlDotNet.dll  *.cs

   4.返回上一级目录 Connector-.Net/ 运行 run.sh脚本，执行：

        bash run.sh [-c]

       注：1).加 -c 表示 生成的结果需要和标准sql文件做比对，
           2).覆盖的sql文件位置：dble-test-suite/drivers/Connector-.Net/netdriver/assets/sql/

       说明：步骤4完成之后会在目录 dble-test-suite/drivers/Connector-.Net/下生成 sql_logs目录，放置sql 执行结果，执行失败的放在 XXX_fail.log中，执行成功的放在 XXX_pass.log中

## 自行搭建该driver测试环境参考：  

   1.下载适配 Centos7的组件 mono,执行：
   
       rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
       su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'
       
   2.安装mono,执行：
   
      yum install -y mono-complete

