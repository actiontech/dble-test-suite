### 一、基础环境

linux Centos7 ，基础环境依赖自行安装: docker, docker-compose, git, wget

### 二、搭建测试环境
    注：目前自动化环境采用docker in docker 模式部署，用户可根据实际需求自行调整

1. 部署外层behave运行环境容器
    

    docker run -itd --privileged --restart=always --name="behave" --hostname="behave" \
    -v /data/docker/volumes/autotest-dble/1:/var/lib/docker \
    -v /share:/share \
    dble/dble_test_behave:latest

2. 下载 dble-test-suite 自动化测试代码至本地
    

    docker exec -it behave bash
    cd && git clone https://github.com/actiontech/dble-test-suite.git
    
    注： 如果dble安装包存放于在内网FTP上，可通过 behave.ini 文件配置ftp信息来下载包
    FTP_USER=xx
    FTP_PASSWORD=xx
    DBLE_REMOTE_HOST=xx
    DBLE_REMOTE_PATH=xx

3. 环境部署 （自动化环境通过 DBLE_DBLE_TOPO 识别single 或cluster ，默认single）
   1. 单机环境
     
      cd /dble_test_suite/behave_dble && make used_in_local
   2. 集群环境
       
       export DBLE_DBLE_TOPO=cluster\
       cd /dble_test_suite/behave_dble && make used_in_local

### 三、执行测试

        cd /dble_test_suite/behave_dble ,根据需要通过make执行相关case



