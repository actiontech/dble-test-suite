linux Centos7 环境下运行 .net driver 代码说明：

1.下载适配 Centos7的组件 mono,执行：
rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'

2.安装mono,执行：
yum install -y mono-complete

3.拷贝 MySql.Data.dll ,YamlDotNet.dll 至源码所在目录 Connector-.Net/netdriver/,执行：
cp  Connector-.Net/packages/MySql.Data.6.10.8/lib/net452/MySql.Data.dll Connector-.Net/netdriver/
cp  Connector-.Net/packages/YamlDotNet.5.3.0/lib/net45/YamlDotNet.dll  Connector-.Net/netdriver/

4.回到自动化项目目录，以拆分表的配置文件重启一遍dble，执行：
behave --stop -D dble_conf=sql_cover_sharding features/setup.feature

5.在源码所在目录 Connector-.Net/netdriver/，执行编译：
csc -out:test.exe -r:MySql.Data.dll -r:YamlDotNet.dll  *.cs

6.在源码所在目录Connector-.Net/netdriver/，运行：
mono test.exe "run" "Properties/auto_dble_test.yaml" "driver_test_manager.sql" "driver_test_client.sql"