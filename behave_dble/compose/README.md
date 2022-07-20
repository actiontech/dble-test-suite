### 一、基础环境

linux Centos7 ，基础环境依赖自行安装: docker, docker-compose, git, wget

### 二、搭建测试环境

     wget https://raw.githubusercontent.com/actiontech/dble-test-suite/master/behave_dble/compose/start_env.sh
     bash start_env.sh

    注：之前下载过的请先关闭所有docker并删除，删除所有相关image和network，重新下载start_env.sh并bash，如果不需要可在脚本中注释掉相关脚本。

### 三、执行测试

     wget https://raw.githubusercontent.com/actiontech/dble-test-suite/master/behave_dble/compose/start_dble_test.sh
     bash start_dble_test.sh

    注：该脚本覆盖了全部功能feature和全局表sql_cover的测试

### 四、driver测试步骤请参考各driver下的readme.md



