# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2023/10/7

# DBLE0REQ-1720 & DBLE0REQ-1748
@skip #需手动执行
Feature: check openSSL and gmSSL

  # 前置步骤：根据issue描述文档链接里的shell脚本生成ca证书，case默认ca证书放在dble-1的/opt/openssl下
  # 注：使用双向认证时，服务端jdk版本不能过高，推荐使用Java 8u121
  Scenario: check openSSL #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="3" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
        <dbInstance name="hostS3" password="111111" url="172.100.9.4:3307" user="test" maxCon="1000" minCon="10" primary="false" />
      </dbGroup>

      <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
        <heartbeat>select 1</heartbeat>
        <dbInstance name="hostM4" password="111111" url="172.100.9.10:9004" user="test" maxCon="100" minCon="10" primary="true" databaseType="clickhouse"/>
      </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" />
       <analysisUser name="ana1" password="111111" dbGroup="ha_group4"  />
       """
    Then execute admin cmd "reload @@config_all"

    # supportSSL type is not boolean
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DsupportSSL=
    """
    Then restart dble in "dble-1" failed for
    """
    property \[ supportSSL \] '' data type should be boolean
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DsupportSSL=/-DsupportSSL=123/
    """
    Then restart dble in "dble-1" failed for
    """
    property \[ supportSSL \] '123' data type should be boolean
    """

    # DBLE0REQ-2299 supportSSL应支持true/false/0/1
    # supportSSL is 0/1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DsupportSSL=123/-DsupportSSL=1/
    """
    Then restart dble in "dble-1" failed for
    """
    property \[ supportSSL \] '1' data type should be boolean
    """

    # isSupportOpenSSL does not support manual config
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DsupportSSL=1/-DsupportSSL=FALSE/
    $a -DisSupportOpenSSL=true
    """
    Then restart dble in "dble-1" failed for
    """
    These properties in bootstrap.cnf or bootstrap.dynamic.cnf are not recognized: isSupportOpenSSL
    """

    # supportSSL=false, other parameters values are wrong
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DsupportSSL=1/-DsupportSSL=FALSE/
    $a -DserverCertificateKeyStoreUrl=aaa
    $a -DserverCertificateKeyStorePwd=123
    $a -DtrustCertificateKeyStoreUrl=bbb
    $a -DtrustCertificateKeyStorePwd=456
    /-DisSupportOpenSSL=/d
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                                  | db               |
      | conn_0 | True    | select * from dble_variables where variable_name in ('isSupportSSL','isSupportOpenSSL','serverCertificateKeyStoreUrl','trustCertificateKeyStoreUrl') | dble_information |
    Then check resultset "rs_1" has lines with following column values
      | variable_name-0              | variable_value-1 | comment-2                               | read_only-3 |
      | isSupportSSL                 | false            | isSupportSSL in configuration           | true        |
      | isSupportOpenSSL             | false            | Whether OpenSSL is actually supported   | true        |
      | serverCertificateKeyStoreUrl | aaa              | Service certificate required of OpenSSL | true        |
      | trustCertificateKeyStoreUrl  | bbb              | Trust certificate required of OpenSSL   | true        |
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose  | sql                                 | expect  | db        |
      | test   | 111111 | conn_1 | True     | drop table if exists sharding_4_t1  | success | schema1   |
      | split1 | 111111 | conn_2 | True     | drop table if exists rw_table       | success | db1       |
      | ana1   | 111111 | conn_3 | True     | create database if not exists ckdb1 | success |           |

    # supportSSL=true, other parameters values are wrong
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DsupportSSL=FALSE/-DsupportSSL=True/
    """
    Given delete file "/opt/dble/logs/wrapper.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    /opt/dble/bin/dble restart
    """
    Then check following text exist "Y" in file "/opt/dble/logs/wrapper.log" in host "dble-1" retry "10" times
    """
    Server startup successfully.
    """
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose  | sql                                 | expect               | db        |
      | test   | 111111 | conn_1 | True     | drop table if exists sharding_4_t1  | SSL connection error | schema1   |
      | split1 | 111111 | conn_2 | True     | drop table if exists rw_table       | SSL connection error | db1       |
      | ana1   | 111111 | conn_3 | True     | create database if not exists ckdb2 | SSL connection error |           |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    com.actiontech.dble.util.exception.NotSupportException: not support OpenSSL
    """
    Given delete file "/opt/dble/logs/tmp.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=DISABLED -e "select * from dble_information.dble_variables where variable_name in ('isSupportSSL','isSupportOpenSSL','serverCertificateKeyStoreUrl','trustCertificateKeyStoreUrl')" | awk '{print $1","$2","}' > /opt/dble/logs/tmp.log
    """
    Then check following text exist "Y" in file "/opt/dble/logs/tmp.log" in host "dble-1"
    """
    variable_name,variable_value,
    isSupportSSL,true,
    isSupportOpenSSL,false,
    serverCertificateKeyStoreUrl,aaa,
    trustCertificateKeyStoreUrl,bbb,
    """
    Given record current dble log line number in "log_line_num1"
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=PREFERRED -e "drop table if exists schema1.sharding_4_t1"
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num1" in host "dble-1"
    """
    com.actiontech.dble.util.exception.NotSupportException: not support OpenSSL
    """

    # supportSSL=true, other parameters values are null
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DserverCertificateKeyStoreUrl=aaa/-DserverCertificateKeyStoreUrl=/
    s/-DserverCertificateKeyStorePwd=123/-DserverCertificateKeyStorePwd=/
    s/-DtrustCertificateKeyStoreUrl=bbb/-DtrustCertificateKeyStoreUrl=/
    s/-DtrustCertificateKeyStorePwd=456/-DtrustCertificateKeyStorePwd=/
    """
    Given delete file "/opt/dble/logs/wrapper.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    /opt/dble/bin/dble restart
    """
    Then check following text exist "Y" in file "/opt/dble/logs/wrapper.log" in host "dble-1" retry "10" times
    """
    Server startup successfully.
    """
    Given delete file "/opt/dble/logs/tmp.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=DISABLED -e "select concat(variable_name,','),concat(variable_value,',') from dble_information.dble_variables where variable_name in ('isSupportSSL','isSupportOpenSSL','serverCertificateKeyStoreUrl','trustCertificateKeyStoreUrl')" > /opt/dble/logs/tmp.log
    """
    Then check following text exist "Y" in file "/opt/dble/logs/tmp.log" in host "dble-1"
    """
    isSupportSSL,\strue,
    isSupportOpenSSL,\sfalse,
    serverCertificateKeyStoreUrl,\s,
    trustCertificateKeyStoreUrl,\s,
    """
    Given record current dble log line number in "log_line_num2"
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=REQUIRED -e "drop table if exists schema1.sharding_4_t1"
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num2" in host "dble-1"
    """
    com.actiontech.dble.util.exception.NotSupportException: not support OpenSSL
    """

    # supportSSL=true, other parameters values are right
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DserverCertificateKeyStoreUrl/d
    /-DtrustCertificateKeyStoreUrl/d
    s/-DserverCertificateKeyStorePwd=/-DserverCertificateKeyStorePwd=123456/
    s/-DtrustCertificateKeyStorePwd=/-DtrustCertificateKeyStorePwd=123456/
    $a -DserverCertificateKeyStoreUrl=/opt/openssl/serverkeystore.jks
    $a -DtrustCertificateKeyStoreUrl=/opt/openssl/truststore.jks
    """
    Given delete file "/opt/dble/logs/wrapper.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    /opt/dble/bin/dble restart
    """
    Then check following text exist "Y" in file "/opt/dble/logs/wrapper.log" in host "dble-1" retry "10" times
    """
    Server startup successfully.
    """

    # 管理端用户5种模式登录
    Given delete file "/opt/dble/logs/tmp.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=DISABLED -e "select * from dble_information.dble_variables where variable_name in ('isSupportSSL','isSupportOpenSSL','serverCertificateKeyStoreUrl','trustCertificateKeyStoreUrl')" | awk '{print $1","$2","}' > /opt/dble/logs/tmp.log
    """
    Then check following text exist "Y" in file "/opt/dble/logs/tmp.log" in host "dble-1"
    """
    variable_name,variable_value,
    isSupportSSL,true,
    isSupportOpenSSL,true,
    serverCertificateKeyStoreUrl,/opt/openssl/serverkeystore.jks,
    trustCertificateKeyStoreUrl,/opt/openssl/truststore.jks,
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=PREFERRED -e "show @@heartbeat;"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=REQUIRED -e "reload @@config_all;"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca.pem -e "show @@backend;"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca.pem --ssl-cert=/opt/openssl/client-cert.pem --ssl-key=/opt/openssl/client-key.pem -e "dryrun;"
    """
    # ssl-key is wrong
    Given execute linux command in "dble-1" and contains exception "SSL connection error: Unable to get private key"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca.pem --ssl-cert=/opt/openssl/client-cert.pem --ssl-key=/opt/openssl/truststore.jks -e "dryrun;"
    """

    # 分库分表用户5种模式登录
    Given record current dble log line number in "log_line_num3"
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=DISABLED -e "use schema1; drop table if exists sharding_4_t1;"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=PREFERRED -e "use schema1; create table sharding_4_t1(id int, name varchar(10));"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=REQUIRED -e "use schema1; insert into sharding_4_t1 values(1,'aa'),(2,'bb');"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca.pem -e "use schema1; update sharding_4_t1 set name='test' where id=2;"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca.pem --ssl-cert=/opt/openssl/client-cert.pem --ssl-key=/opt/openssl/client-key.pem -e "use schema1; select * from sharding_4_t1;"
    """
    # ssl-ca is wrong
    Given execute linux command in "dble-1" and contains exception "SSL connection error: ASN: bad other signature confirmation"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca-key.pem -e "use schema1; delete from sharding_4_t1;"
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num3" in host "dble-1"
    """
    ssl = no\] query sql: drop table if exists sharding_4_t1
    ssl = OpenSSL\] query sql: create table sharding_4_t1\(id int, name varchar\(10\)\)
    ssl = OpenSSL\] query sql: insert into sharding_4_t1 values\(1,'aa'\),\(2,'bb'\)
    ssl = OpenSSL\] query sql: update sharding_4_t1 set name='test' where id=2
    ssl = OpenSSL\] query sql: select \* from sharding_4_t1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_line_num3" in host "dble-1"
    """
    ssl = OpenSSL\] query sql: drop table if exists sharding_4_t1
    """

    # 读写分离用户5种模式登录
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -usplit1 -h{node:ip} --ssl-mode=DISABLED -e "use db1; drop table if exists rw_table;"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -usplit1 -h{node:ip} --ssl-mode=PREFERRED -e "use db1; create table rw_table(id int, name varchar(10));"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -usplit1 -h{node:ip} --ssl-mode=REQUIRED -e "use db1; insert into rw_table values(1,'aa'),(2,'bb');"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -usplit1 -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca.pem -e "use db1; update rw_table set name='test' where id=2;"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -usplit1 -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca.pem --ssl-cert=/opt/openssl/client-cert.pem --ssl-key=/opt/openssl/client-key.pem -e "use db1; select * from rw_table;"
    """
    # ssl-ca is wrong
    Given execute linux command in "dble-1" and contains exception "SSL connection error: ASN: bad other signature confirmation"
    """
    mysql -P{node:client_port} -usplit1 -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca-key.pem -e "use db1; delete from rw_table;"
    """

    # 分析用户5种模式登录
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -uana1 -h{node:ip} --ssl-mode=DISABLED -e "use ckdb1; show tables;"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -uana1 -h{node:ip} --ssl-mode=PREFERRED -e "use ckdb1; show tables;"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -uana1 -h{node:ip} --ssl-mode=REQUIRED -e "use ckdb1; select 1;"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -uana1 -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca.pem -e "use ckdb1; select 1;"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -uana1 -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca.pem --ssl-cert=/opt/openssl/client-cert.pem --ssl-key=/opt/openssl/client-key.pem -e "use ckdb1; select 1;"
    """
    # ssl-ca is wrong
    Given execute linux command in "dble-1" and contains exception "SSL connection error: ASN: bad other signature confirmation"
    """
    mysql -P{node:client_port} -uana1 -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/openssl/ca-key.pem -e "use ckdb1; show tables;"
    """


  # 前置步骤：
  # 1、jdk替换以下jar包：gmssl_provider.jar放到jre/lib/ext下；local_policy.jar、US_export_policy.jar放到jre/lib/security下
  # 2、下载专门的dble-gmssl包安装dble
  # 3、在国密官网生成数字证书（包括服务器和个人）
  # 注：使用双向认证时，服务端jdk版本不能过高，推荐使用Java 8u121
  Scenario: check GMSSL #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group3" delayThreshold="100">
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
      <dbInstance name="hostS3" password="111111" url="172.100.9.4:3307" user="test" maxCon="1000" minCon="10" primary="false" />
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
      <heartbeat>select 1</heartbeat>
      <dbInstance name="hostM4" password="111111" url="172.100.9.10:9004" user="test" maxCon="100" minCon="10" primary="true" databaseType="clickhouse"/>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" />
    <analysisUser name="ana1" password="111111" dbGroup="ha_group4"  />
    """
    Then execute admin cmd "reload @@config_all"

    # isSupportGMSSL does not support manual config
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DisSupportGMSSL=true
    """
    Then restart dble in "dble-1" failed for
    """
    These properties in bootstrap.cnf or bootstrap.dynamic.cnf are not recognized: isSupportGMSSL
    """

    # supportSSL=false, other parameters values are wrong
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DsupportSSL=false
    $a -DgmsslBothPfx=aaa
    $a -DgmsslBothPfxPwd=123
    $a -DgmsslRcaPem=bbb
    $a -DgmsslOcaPem=456
    /-DisSupportGMSSL=/d
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                           | db               |
      | conn_0 | True    | select * from dble_variables where variable_name like '%ssl%' | dble_information |
    Then check resultset "rs_1" has lines with following column values
      | variable_name-0  | variable_value-1 | comment-2                                                       | read_only-3 |
      | isSupportSSL     | false            | isSupportSSL in configuration                                   | true        |
      | isSupportOpenSSL | false            | Whether OpenSSL is actually supported                           | true        |
      | isSupportGMSSL   | false            | Whether GMSSL is actually supported                             | true        |
      | gmsslBothPfx     | aaa              | National secret dual certificate/private key file in PFX format | true        |
      | gmsslRcaPem      | bbb              | Root certificate of GMSSL                                       | true        |
      | gmsslOcaPem      | 456              | Secondary certificate of GMSSL                                  | true        |
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose  | sql                                 | expect  | db        |
      | test   | 111111 | conn_1 | True     | drop table if exists sharding_4_t1  | success | schema1   |
      | split1 | 111111 | conn_2 | True     | drop table if exists rw_table       | success | db1       |
      | ana1   | 111111 | conn_3 | True     | create database if not exists ckdb1 | success |           |

    # supportSSL=true, other parameters values are wrong
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DsupportSSL=false/-DsupportSSL=true/
    """
    Given delete file "/opt/dble/logs/wrapper.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    /opt/dble/bin/dble restart
    """
    Then check following text exist "Y" in file "/opt/dble/logs/wrapper.log" in host "dble-1" retry "10" times
    """
    Server startup successfully.
    """
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose  | sql                                 | expect               | db        |
      | test   | 111111 | conn_1 | True     | drop table if exists sharding_4_t1  | SSL connection error | schema1   |
      | split1 | 111111 | conn_2 | True     | drop table if exists rw_table       | SSL connection error | db1       |
      | ana1   | 111111 | conn_3 | True     | create database if not exists ckdb2 | SSL connection error |           |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    com.actiontech.dble.util.exception.NotSupportException: not support OpenSSL
    """
    Given delete file "/opt/dble/logs/tmp.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=DISABLED -e "select * from dble_information.dble_variables where variable_name like '%ssl%';" | awk '{print $1","$2","}' > /opt/dble/logs/tmp.log
    """
    Then check following text exist "Y" in file "/opt/dble/logs/tmp.log" in host "dble-1"
    """
    variable_name,variable_value,
    isSupportSSL,true,
    isSupportOpenSSL,false,
    isSupportGMSSL,false,
    gmsslBothPfx,aaa,
    gmsslRcaPem,bbb,
    gmsslOcaPem,456,
    """
    Given record current dble log line number in "log_line_num1"
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=PREFERRED -e "drop table if exists schema1.sharding_4_t1"
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num1" in host "dble-1"
    """
    com.actiontech.dble.util.exception.NotSupportException: not support OpenSSL
    """

    # supportSSL=true, other parameters values are null
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DgmsslBothPfx=aaa/-DgmsslBothPfx=/
    s/-DgmsslBothPfxPwd=123/-DgmsslBothPfxPwd=/
    s/-DgmsslRcaPem=bbb/-DgmsslRcaPem=/
    s/-DgmsslOcaPem=456/-DgmsslOcaPem=/
    """
    Given delete file "/opt/dble/logs/wrapper.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    /opt/dble/bin/dble restart
    """
    Then check following text exist "Y" in file "/opt/dble/logs/wrapper.log" in host "dble-1" retry "10" times
    """
    Server startup successfully.
    """
    Given delete file "/opt/dble/logs/tmp.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=DISABLED -e "select concat(variable_name,','),concat(variable_value,',') from dble_information.dble_variables where variable_name like '%ssl%'" > /opt/dble/logs/tmp.log
    """
    Then check following text exist "Y" in file "/opt/dble/logs/tmp.log" in host "dble-1"
    """
    isSupportSSL,\strue,
    isSupportOpenSSL,\sfalse,
    isSupportGMSSL,\sfalse,
    gmsslBothPfx,\s,
    gmsslRcaPem,\s,
    gmsslOcaPem,\s,
    """
    Given record current dble log line number in "log_line_num2"
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=REQUIRED -e "drop table if exists schema1.sharding_4_t1"
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num2" in host "dble-1"
    """
    com.actiontech.dble.util.exception.NotSupportException: not support OpenSSL
    """

    # supportSSL=true, other parameters values are right
    # gmsslBothPfx参数值中的dble-test为申请证书时填写的项目名称
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DgmsslBothPfx/d
    /-DgmsslBothPfxPwd/d
    /-DgmsslRcaPem/d
    /-DgmsslOcaPem/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DgmsslBothPfx=/opt/gmssl/sm2.dble-test.both.pfx
    $a -DgmsslBothPfxPwd=12345678
    $a -DgmsslRcaPem=/opt/gmssl/sm2.rca.pem
    $a -DgmsslOcaPem=/opt/gmssl/sm2.oca.pem
    """
    Given delete file "/opt/dble/logs/wrapper.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    /opt/dble/bin/dble restart
    """
    Then check following text exist "Y" in file "/opt/dble/logs/wrapper.log" in host "dble-1" retry "10" times
    """
    Server startup successfully.
    """

    # 管理端用户各种模式登录 - 只支持disabled模式
    Given delete file "/opt/dble/logs/tmp.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=DISABLED -e "select * from dble_information.dble_variables where variable_name like '%ssl%'" | awk '{print $1","$2","}' > /opt/dble/logs/tmp.log
    """
    Then check following text exist "Y" in file "/opt/dble/logs/tmp.log" in host "dble-1"
    """
    variable_name,variable_value,
    isSupportSSL,true,
    isSupportOpenSSL,false,
    isSupportGMSSL,true,
    gmsslBothPfx,/opt/gmssl/sm2.dble-test.both.pfx,
    gmsslRcaPem,/opt/gmssl/sm2.rca.pem,
    gmsslOcaPem,/opt/gmssl/sm2.oca.pem,
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=PREFERRED -e "show @@heartbeat;"
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=REQUIRED -e "reload @@config_all;"
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/gmssl/sm2.rca.pem -e "show @@backend;"
    """


    # 分库分表用户各种模式登录 - 只支持disabled模式
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=DISABLED -e "drop table if exists schema1.sharding_4_t1;"
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=PREFERRED -e "create table schema1.sharding_4_t1(id int, name varchar(10));"
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=REQUIRED -e "insert into schema1.sharding_4_t1 values(1,'aa'),(2,'bb');"
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/gmssl/sm2.rca.pem -e "update schema1.sharding_4_t1 set name='test' where id=2;"
    """

    # 读写分离用户5种模式登录 - 只支持disabled模式
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -usplit1 -h{node:ip} --ssl-mode=DISABLED -e "drop table if exists db1.rw_table;"
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -usplit1 -h{node:ip} --ssl-mode=PREFERRED -e "create table db1.rw_table(id int, name varchar(10));"
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -usplit1 -h{node:ip} --ssl-mode=REQUIRED -e "insert into db1.rw_table values(1,'aa'),(2,'bb');"
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -usplit1 -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/gmssl/sm2.rca.pem -e "update db1.rw_table set name='test' where id=2;"
    """

    # 分析用户5种模式登录 - 只支持disabled模式
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -uana1 -h{node:ip} --ssl-mode=DISABLED -e "use ckdb1; show tables;"
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -uana1 -h{node:ip} --ssl-mode=PREFERRED -e "use ckdb1; show tables;"
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -uana1 -h{node:ip} --ssl-mode=REQUIRED -e "use ckdb1; select 1;"
    """
    Given execute linux command in "dble-1" and contains exception "SSL connection error: socket layer receive error"
    """
    mysql -P{node:client_port} -uana1 -h{node:ip} --ssl-mode=VERIFY_CA --ssl-ca=/opt/gmssl/sm2.rca.pem -e "use ckdb1; select 1;"
    """
