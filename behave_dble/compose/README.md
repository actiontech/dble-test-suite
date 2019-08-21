### 一、基础环境

linux Centos7 ，基础环境依赖自行安装: docker,docker-compose,python 2.7, git, wget

### 二、搭建测试环境

     wget https://github.com/actiontech/dble-test-suite/blob/master/behave_dble/compose/start_env.sh
     bash start_env.sh

### 三、执行测试

     wget https://github.com/actiontech/dble-test-suite/blob/master/behave_dble/compose/start_dble_test.sh
     bash start_dble_test.sh

    注：该脚本覆盖了全部功能feature和全局表sql_cover的测试

### 四、driver测试步骤请参考各driver下的readme.md



