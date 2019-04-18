steps for running .net code in linux system:
1.download mono for Centos 7
rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'
2.install mono
yum install -y mono-complete
3.copy the packages we needed(MySql.Data.dll ,YamlDotNet.dll) from packages directory 
copy the MySql.Data.dll ,YamlDotNet.dll to the directory where *.cs programmes located
4.在 netdirver 目录 compile for console :
csc -out:test.exe -r:MySql.Data.dll -r:YamlDotNet.dll  *.cs
5.执行：behave --stop -D dble_conf=sql_cover_sharding features/setup.feature
6.在 netdirver 目录 exec for console
mono test.exe "run" "Properties/auto_dble_test.yaml" "driver_test_manager.sql" "driver_test_client.sql"