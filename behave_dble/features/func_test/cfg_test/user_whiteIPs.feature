# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/1/4

Feature: check whiteIPs in user.xml

  Scenario: whiteIPs format verification #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111" readOnly="false" whiteIPs="172.100.9.1000"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    The configuration contains incorrect IP["172.100.9.1000"]
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" whiteIPs="172.100.9"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    The configuration contains incorrect IP["172.100.9"]
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" whiteIPs="172.100.9.1a"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    The configuration contains incorrect IP["172.100.9.1a"]
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1" />
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group1" whiteIPs="172.100.9.1,a1G-@"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    The configuration contains incorrect IP["a1G-@"]
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group2" whiteIPs="172.100.9.1-172.100.9.8888"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    The configuration contains incorrect IP["172.100.9.1-172.100.9.8888"]
    """

  Scenario: whiteIPs support localhost #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
      </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root1" password="111111" whiteIPs=""/>
    <managerUser name="root2" password="111111" whiteIPs="127.0.0.1"/>
    <managerUser name="root3" password="111111" whiteIPs="0:0:0:0:0:0:0:1"/>

    <shardingUser name="test1" password="111111" schemas="schema1" whiteIPs=""/>
    <shardingUser name="test2" password="111111" schemas="schema1" whiteIPs="127.0.0.1"/>
    <shardingUser name="test3" password="111111" schemas="schema1" whiteIPs="0:0:0:0:0:0:0:1"/>

    <rwSplitUser name="split" password="111111" dbGroup="ha_group3" />
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" whiteIPs=""/>
    <rwSplitUser name="split2" password="111111" dbGroup="ha_group3" whiteIPs="127.0.0.1"/>
    <rwSplitUser name="split3" password="111111" dbGroup="ha_group3" whiteIPs="0:0:0:0:0:0:0:1"/>
    """
    Then execute admin cmd "reload @@config_all"

# managerUser - not set whiteIps
    Then execute admin cmd "show @@version" with user "root" passwd "111111"
    Given connect "dble-1" with user "admin" in "mysql-master1" to execute sql
    """
    show @@version
    """

# managerUser - whiteIps is blank
    Given execute linux command in "mysql-slave2"
    """
    mysql -P9066 -uroot1 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P9066 -uroot1 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql"
    """
    mysql -P9066 -uroot1 -h172.100.9.1 -e "show @@version"
    """
# managerUser whiteIps=127.0.0.1
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -uroot2 -h127.0.0.1 -e "show @@version"
    mysql -P{node:manager_port} -uroot2 -h0:0:0:0:0:0:0:1 -e "show @@version"
    """
    Given execute linux command in "mysql-slave1" and contains exception "Access denied for user 'root2' with host '172.100.9.6'"
    """
    mysql -P9066 -uroot2 -h172.100.9.1 -e "show @@version"
    """
# managerUser whiteIps=0:0:0:0:0:0:0:1
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -uroot3 -h0:0:0:0:0:0:0:1 -e "show @@version"
    mysql -P{node:manager_port} -uroot3 -h127.0.0.1 -e "show @@version"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'root3' with host '172.100.9.6'"
    """
    mysql -P9066 -uroot3 -h172.100.9.1 -e "show @@version"
    """

# shardingUser - not set whiteIps
    Given connect "dble-1" with user "test" in "mysql-master1" to execute sql
    """
    select version()
    """
    Given connect "dble-1" with user "test" in "mysql-master2" to execute sql
    """
    select version()
    """

# shardingUser - whiteIps is blank
    Given execute linux command in "mysql-slave2"
    """
    mysql -P8066 -utest1 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -utest1 -h172.100.9.1 -e "select version()"
    """

# shardingUser whiteIps=127.0.0.1
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -utest2 -h127.0.0.1 -e "select version()"
    """
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test2' with host '0:0:0:0:0:0:0:1'"
    """
    mysql -P{node:client_port} -utest2 -h0:0:0:0:0:0:0:1 -e "select version()"
    """
    Given execute linux command in "mysql" and contains exception "Access denied for user 'test2' with host '172.100.9.4'"
    """
    mysql -P8066 -utest2 -h172.100.9.1 -e "select version()"
    """
# shardingUser whiteIps=0:0:0:0:0:0:0:1
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -utest3 -h0:0:0:0:0:0:0:1 -e "select version()"
    """
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test3' with host '127.0.0.1'"
    """
    mysql -P{node:client_port} -utest3 -h127.0.0.1 -e "select version()"
    """
    Given execute linux command in "mysql-master1" and contains exception "Access denied for user 'test3' with host '172.100.9.5'"
    """
    mysql -P8066 -utest3 -h172.100.9.1 -e "select version()"
    """

# rwSplitUser - not set whiteIps
    Given execute linux command in "mysql"
    """
    mysql -P8066 -usplit -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-slave1"
    """
    mysql -P8066 -usplit -h172.100.9.1 -e "select version()"
    """
# rwSplitUser - whiteIps is blank
    Given execute linux command in "mysql-slave2"
    """
    mysql -P8066 -usplit1 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -usplit1 -h172.100.9.1 -e "select version()"
    """

# rwSplitUser whiteIps=127.0.0.1
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -usplit2 -h127.0.0.1 -e "select version()"
    """
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'split2' with host '0:0:0:0:0:0:0:1'"
    """
    mysql -P{node:client_port} -usplit2 -h0:0:0:0:0:0:0:1 -e "select version()"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'split2' with host '172.100.9.6'"
    """
    mysql -P8066 -usplit2 -h172.100.9.1 -e "select version()"
    """
# rwSplitUser whiteIps=0:0:0:0:0:0:0:1
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -usplit3 -h0:0:0:0:0:0:0:1 -e "select version()"
    """
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'split3' with host '127.0.0.1'"
    """
    mysql -P{node:client_port} -usplit3 -h127.0.0.1 -e "select version()"
    """
    Given execute linux command in "mysql-slave1" and contains exception "Access denied for user 'split3' with host '172.100.9.6'"
    """
    mysql -P8066 -usplit3 -h172.100.9.1 -e "select version()"
    """

  Scenario: whiteIps support single IP, multiple IP, IP segment #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
      </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root1" password="111111" whiteIPs="172.100.9.4"/>
    <managerUser name="root2" password="111111" whiteIPs="172.100.9.4,172.100.9.5"/>
    <managerUser name="root3" password="111111" whiteIPs="172.100.9.1-172.100.9.4,172.100.9.5"/>

    <shardingUser name="test1" password="111111" schemas="schema1" whiteIPs="172.100.9.5"/>
    <shardingUser name="test2" password="111111" schemas="schema1" whiteIPs="172.100.9.5,172.100.9.6"/>
    <shardingUser name="test3" password="111111" schemas="schema1" whiteIPs="172.100.9.1-172.100.9.4,172.100.9.5"/>

    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" whiteIPs="172.100.9.2"/>
    <rwSplitUser name="split2" password="111111" dbGroup="ha_group3" whiteIPs="172.100.9.3,172.100.9.5"/>
    <rwSplitUser name="split3" password="111111" dbGroup="ha_group3" whiteIPs="172.100.9.1-172.100.9.2,172.100.9.4-172.100.9.6,172.100.9.10"/>
    """
    Then execute admin cmd "reload @@config_all"

# managerUser - localhost
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -uroot1 -h0:0:0:0:0:0:0:1 -e "show @@version"
    mysql -P{node:manager_port} -uroot1 -h127.0.0.1 -e "show @@version"
    mysql -P{node:manager_port} -uroot2 -h0:0:0:0:0:0:0:1 -e "show @@version"
    mysql -P{node:manager_port} -uroot2 -h127.0.0.1 -e "show @@version"
    mysql -P{node:manager_port} -uroot3 -h0:0:0:0:0:0:0:1 -e "show @@version"
    mysql -P{node:manager_port} -uroot3 -h127.0.0.1 -e "show @@version"
    """
# managerUser - single IP
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'root1' with host '172.100.9.1'"
    """
    mysql -P{node:manager_port} -uroot1 -h{node:ip} -e "show @@version"
    """
    Given execute linux command in "mysql"
    """
    mysql -P9066 -uroot1 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'root1' with host '172.100.9.6'"
    """
    mysql -P9066 -uroot1 -h172.100.9.1 -e "show @@version"
    """
# managerUser - multiple IP
    Given execute linux command in "mysql-slave1" and contains exception "Access denied for user 'root2' with host '172.100.9.6'"
    """
    mysql -P9066 -uroot2 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P9066 -uroot2 -h172.100.9.1 -e "show @@version"
    """
# managerUser - IP segment
    Given execute linux command in "dble-1"
    """
    mysql -P{node:manager_port} -uroot3 -h{node:ip} -e "show @@version"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P9066 -uroot3 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'root3' with host '172.100.9.6'"
    """
    mysql -P9066 -uroot3 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql"
    """
    mysql -P9066 -uroot3 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql-master2" and contains exception "Access denied for user 'root3' with host '172.100.9.6'"
    """
    mysql -P9066 -uroot3 -h172.100.9.1 -e "show @@version"
    """


# shardingUser - localhost
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test1' with host '0:0:0:0:0:0:0:1'"
    """
    mysql -P{node:client_port} -utest1 -h0:0:0:0:0:0:0:1 -e "select version()"
    """
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test1' with host '127.0.0.1'"
    """
    mysql -P{node:client_port} -utest1 -h127.0.0.1 -e "select version()"
    """
# shardingUser - single IP
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test1' with host '172.100.9.1'"
    """
    mysql -P8066 -utest1 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
  """
    mysql -P8066 -utest1 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-master2" and contains exception "Access denied for user 'test1' with host '172.100.9.6'"
  """
    mysql -P8066 -utest1 -h172.100.9.1 -e "select version()"
    """
# shardingUser - multiple IP
    Given execute linux command in "mysql" and contains exception "Access denied for user 'test2' with host '172.100.9.4'"
    """
    mysql -P8066 -utest2 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-slave2"
    """
    mysql -P8066 -utest2 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -utest2 -h172.100.9.1 -e "select version()"
    """
# shardingUser - IP segment
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -utest3 -h{node:ip} -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -utest3 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'test3' with host '172.100.9.6'"
    """
    mysql -P8066 -utest3 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql"
    """
    mysql -P8066 -utest3 -h172.100.9.1 -e "select version()"
    """

# rwSplitUser - localhost
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'split1' with host '0:0:0:0:0:0:0:1'"
    """
    mysql -P{node:client_port} -usplit1 -h0:0:0:0:0:0:0:1 -e "select version()"
    """
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'split1' with host '127.0.0.1'"
    """
    mysql -P{node:client_port} -usplit1 -h127.0.0.1 -e "select version()"
    """
# rwSplitUser - single IP
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'split1' with host '172.100.9.1'"
    """
    mysql -P8066 -usplit1 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-slave1" and contains exception "Access denied for user 'split1' with host '172.100.9.6'"
    """
    mysql -P8066 -usplit1 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-master1" and contains exception "Access denied for user 'split1' with host '172.100.9.5'"
    """
    mysql -P8066 -usplit1 -h172.100.9.1 -e "select version()"
    """
# rwSplitUser - multiple IP
    Given execute linux command in "mysql" and contains exception "Access denied for user 'split2' with host '172.100.9.4'"
    """
    mysql -P8066 -usplit2 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'split2' with host '172.100.9.6'"
    """
    mysql -P8066 -usplit2 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -usplit2 -h172.100.9.1 -e "select version()"
    """
# rwSplitUser - IP segment
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -usplit3 -h{node:ip} -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -usplit3 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-slave2"
    """
    mysql -P8066 -usplit3 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql"
    """
    mysql -P8066 -usplit3 -h172.100.9.1 -e "select version()"
    """

  Scenario: whiteIps support IPV6 #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
      </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root1" password="111111" whiteIPs="2001:3984:3989::14"/>
    <managerUser name="root2" password="111111" whiteIPs="2001:3984:3989::14,2001:3984:3989:0:0:0:0:15"/>
    <managerUser name="root3" password="111111" whiteIPs="2001:3984:3989::11-2001:3984:3989::13,2001:3984:3989:0000:0000:0000:0000:0014,172.100.9.5"/>
    <managerUser name="root4" password="111111" whiteIPs="2001:3984:3989:0000:0000:0000:0000:0014-2001:3984:3989:0:0:0:0:15"/>

    <shardingUser name="test1" password="111111" schemas="schema1" whiteIPs="2001:3984:3989::15"/>
    <shardingUser name="test2" password="111111" schemas="schema1" whiteIPs="2001:3984:3989::15,2001:3984:3989:0:0:0:0:16"/>
    <shardingUser name="test3" password="111111" schemas="schema1" whiteIPs="2001:3984:3989::11-2001:3984:3989::13,2001:3984:3989:0000:0000:0000:0000:0014,172.100.9.5"/>
    <shardingUser name="test4" password="111111" schemas="schema1" whiteIPs="2001:3984:3989:0000:0000:0000:0000:0014-2001:3984:3989:0:0:0:0:15"/>

    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" whiteIPs="2001:3984:3989::16"/>
    <rwSplitUser name="split2" password="111111" dbGroup="ha_group3" whiteIPs="2001:3984:3989::15,2001:3984:3989:0:0:0:0:16"/>
    <rwSplitUser name="split3" password="111111" dbGroup="ha_group3" whiteIPs="2001:3984:3989::11-2001:3984:3989::13,2001:3984:3989:0000:0000:0000:0000:0014,172.100.9.5"/>
    <rwSplitUser name="split4" password="111111" dbGroup="ha_group3" whiteIPs="2001:3984:3989:0000:0000:0000:0000:0014-2001:3984:3989:0:0:0:0:15"/>
    """
    Then execute admin cmd "reload @@config_all"

# managerUser - single IP
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'root1' with host '2001:3984:3989:0:0:0:0:11'"
    """
    mysql -P{node:manager_port} -uroot1 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "show @@version"
    """
    Given execute linux command in "mysql"
    """
    mysql -P9066 -uroot1 -h2001:3984:3989:0:0:0:0:11 -e "show @@version"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'root1' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P9066 -uroot1 -h2001:3984:3989::11 -e "show @@version"
    """
# managerUser - multiple IP
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'root2' with host '2001:3984:3989:0:0:0:0:11'"
    """
    mysql -P{node:manager_port} -uroot2 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "show @@version"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P9066 -uroot2 -h2001:3984:3989:0:0:0:0:11 -e "show @@version"
    """
    Given execute linux command in "mysql"
    """
    mysql -P9066 -uroot2 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "show @@version"
    """
    Given execute linux command in "mysql-master2" and contains exception "Access denied for user 'root2' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P9066 -uroot2 -h2001:3984:3989::11 -e "show @@version"
    """
# managerUser - IPV4 and IPV6
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'root3' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P9066 -uroot3 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "show @@version"
    """
    Given execute linux command in "mysql"
    """
    mysql -P9066 -uroot3 -h2001:3984:3989:0:0:0:0:11 -e "show @@version"
    """
    Given execute linux command in "mysql-master1" and contains exception "Access denied for user 'root3' with host '2001:3984:3989:0:0:0:0:15'"
    """
    mysql -P9066 -uroot3 -h2001:3984:3989::11 -e "show @@version"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P9066 -uroot3 -h172.100.9.1 -e "show @@version"
    """

# managerUser - IPV6 whole format
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'root4' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P9066 -uroot4 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "show @@version"
    """
    Given execute linux command in "mysql"
    """
    mysql -P9066 -uroot4 -h2001:3984:3989:0:0:0:0:11 -e "show @@version"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P9066 -uroot4 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "show @@version"
    """

# shardingUser - single IP
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test1' with host '2001:3984:3989:0:0:0:0:11'"
    """
    mysql -P8066 -utest1 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -utest1 -h2001:3984:3989:0:0:0:0:11 -e "select version()"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'test1' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P8066 -utest1 -h2001:3984:3989::11 -e "select version()"
    """
# shardingUser - multiple IP
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test2' with host '2001:3984:3989:0:0:0:0:11'"
    """
    mysql -P8066 -utest2 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """
    Given execute linux command in "mysql-slave1"
    """
    mysql -P8066 -utest2 -h2001:3984:3989:0:0:0:0:11 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -utest2 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """
    Given execute linux command in "mysql" and contains exception "Access denied for user 'test2' with host '2001:3984:3989:0:0:0:0:14'"
    """
    mysql -P8066 -utest2 -h2001:3984:3989::11 -e "select version()"
    """
# shardingUser - IPV4 and IPV6
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'test3' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P8066 -utest3 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """
    Given execute linux command in "mysql"
    """
    mysql -P8066 -utest3 -h2001:3984:3989:0:0:0:0:11 -e "select version()"
    """
     Given execute linux command in "mysql-master1" and contains exception "Access denied for user 'test3' with host '2001:3984:3989:0:0:0:0:15'"
    """
    mysql -P8066 -utest3 -h2001:3984:3989::11 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -utest3 -h172.100.9.1 -e "select version()"
    """

# shardingUser - IPV6 whole format
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'test4' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P8066 -utest4 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """
    Given execute linux command in "mysql"
    """
    mysql -P8066 -utest4 -h2001:3984:3989:0:0:0:0:11 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -utest4 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """
   
# rwSplitUser - single IP
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'split1' with host '2001:3984:3989:0:0:0:0:11'"
    """
    mysql -P8066 -usplit1 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """
    Given execute linux command in "mysql-slave1"
    """
    mysql -P8066 -usplit1 -h2001:3984:3989:0:0:0:0:11 -e "select version()"
    """
    Given execute linux command in "mysql-master1" and contains exception "Access denied for user 'split1' with host '2001:3984:3989:0:0:0:0:15'"
    """
    mysql -P8066 -usplit1 -h2001:3984:3989::11 -e "select version()"
    """
# rwSplitUser - multiple IP
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'split2' with host '2001:3984:3989:0:0:0:0:11'"
    """
    mysql -P8066 -usplit2 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -usplit2 -h2001:3984:3989:0:0:0:0:11 -e "select version()"
    """
    Given execute linux command in "mysql-slave2"
    """
    mysql -P8066 -usplit2 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """
    Given execute linux command in "mysql" and contains exception "Access denied for user 'split2' with host '2001:3984:3989:0:0:0:0:14'"
    """
    mysql -P8066 -usplit2 -h2001:3984:3989::11 -e "select version()"
    """
# rwSplitUser - IPV4 and IPV6
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'split3' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P8066 -usplit3 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """
    Given execute linux command in "mysql"
    """
    mysql -P8066 -usplit3 -h2001:3984:3989:0:0:0:0:11 -e "select version()"
    """
    Given execute linux command in "mysql-master1" and contains exception "Access denied for user 'split3' with host '2001:3984:3989:0:0:0:0:15'"
    """
    mysql -P8066 -usplit3 -h2001:3984:3989::11 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -usplit3 -h172.100.9.1 -e "select version()"
    """

# rwSplitUser - IPV6 whole format
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'split4' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P8066 -usplit4 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """
    Given execute linux command in "mysql"
    """
    mysql -P8066 -usplit4 -h2001:3984:3989:0:0:0:0:11 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -usplit4 -h2001:3984:3989:0000:0000:0000:0000:0011 -e "select version()"
    """

  Scenario: whiteIps support CIDR #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
      </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root1" password="111111" whiteIPs="%.%.%.%"/>
    <managerUser name="root2" password="111111" whiteIPs="0.0.0.0"/>
    <managerUser name="root3" password="111111" whiteIPs="0.0.0.0/0"/>
    <managerUser name="root4" password="111111" whiteIPs="172.100.8.%"/>
    <managerUser name="root5" password="111111" whiteIPs="172.100.9.0/24"/>
    <managerUser name="root6" password="111111" whiteIPs="172.100.9.0/30"/>
    <managerUser name="root7" password="111111" whiteIPs="2001:3984:3989::0/127"/>
    <managerUser name="root8" password="111111" whiteIPs="2001:3984:3989::0/123"/>

    <shardingUser name="test1" password="111111" schemas="schema1" whiteIPs="%.%.%.%"/>
    <shardingUser name="test2" password="111111" schemas="schema1" whiteIPs="0.0.0.0"/>
    <shardingUser name="test3" password="111111" schemas="schema1" whiteIPs="0.0.0.0/0"/>
    <shardingUser name="test4" password="111111" schemas="schema1" whiteIPs="172.100.8.%"/>
    <shardingUser name="test5" password="111111" schemas="schema1" whiteIPs="172.100.9.0/24"/>
    <shardingUser name="test6" password="111111" schemas="schema1" whiteIPs="172.100.9.0/30"/>
    <shardingUser name="test7" password="111111" schemas="schema1" whiteIPs="2001:3984:3989::0/127"/>
    <shardingUser name="test8" password="111111" schemas="schema1" whiteIPs="2001:3984:3989::0/123"/>

    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" whiteIPs="%.%.%.%"/>
    <rwSplitUser name="split2" password="111111" dbGroup="ha_group3" whiteIPs="0.0.0.0"/>
    <rwSplitUser name="split3" password="111111" dbGroup="ha_group3" whiteIPs="0.0.0.0/0"/>
    <rwSplitUser name="split4" password="111111" dbGroup="ha_group3" whiteIPs="172.100.8.%"/>
    <rwSplitUser name="split5" password="111111" dbGroup="ha_group3" whiteIPs="172.100.9.0/24"/>
    <rwSplitUser name="split6" password="111111" dbGroup="ha_group3" whiteIPs="172.100.9.0/30"/>
    <rwSplitUser name="split7" password="111111" dbGroup="ha_group3" whiteIPs="2001:3984:3989::0/127"/>
    <rwSplitUser name="split8" password="111111" dbGroup="ha_group3" whiteIPs="2001:3984:3989::0/123"/>
    """
    Then execute admin cmd "reload @@config_all"

# managerUser - %.%.%.%
    Given execute linux command in "mysql-slave1"
    """
    mysql -P9066 -uroot1 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql"
    """
    mysql -P9066 -uroot1 -h172.100.9.1 -e "show @@version"
    """
# managerUser - 0.0.0.0
    Given execute linux command in "dble-1"
    """
    mysql -P9066 -uroot2 -h127.0.0.1 -e "show @@version"
    """
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'root2' with host '172.100.9.1'"
    """
    mysql -P9066 -uroot2 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql-master1" and contains exception "Access denied for user 'root2' with host '172.100.9.5'"
    """
    mysql -P9066 -uroot2 -h172.100.9.1 -e "show @@version"
    """
# managerUser - 0.0.0.0/0
    Given execute linux command in "dble-1"
    """
    mysql -P9066 -uroot3 -h127.0.0.1 -e "show @@version"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P9066 -uroot3 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P9066 -uroot3 -h172.100.9.1 -e "show @@version"
    """
# managerUser - 172.100.8.%
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'root4' with host '172.100.9.1'"
    """
    mysql -P9066 -uroot4 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'root4' with host '172.100.9.6'"
    """
    mysql -P9066 -uroot4 -h172.100.9.1 -e "show @@version"
    """
# managerUser - 172.100.9.0/24
    Given execute linux command in "dble-1"
    """
    mysql -P9066 -uroot5 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql-slave2"
    """
    mysql -P9066 -uroot5 -h172.100.9.1 -e "show @@version"
    """
# managerUser - 172.100.9.0/30
    Given execute linux command in "dble-1"
    """
    mysql -P9066 -uroot6 -h172.100.9.1 -e "show @@version"
    """
    Given execute linux command in "mysql" and contains exception "Access denied for user 'root6' with host '172.100.9.4'"
    """
    mysql -P9066 -uroot6 -h172.100.9.1 -e "show @@version"
    """
# managerUser - 2001:3984:3989::0/127
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'root7' with host '2001:3984:3989:0:0:0:0:11'"
    """
    mysql -P9066 -uroot7 -h2001:3984:3989::11 -e "show @@version"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'root7' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P9066 -uroot7 -h2001:3984:3989::11 -e "show @@version"
    """
# managerUser - 2001:3984:3989::0/123
    Given execute linux command in "dble-1"
    """
    mysql -P9066 -uroot8 -h2001:3984:3989::11 -e "show @@version"
    """
    Given execute linux command in "mysql-master2"
    """
    mysql -P9066 -uroot8 -h2001:3984:3989::11 -e "show @@version"
    """
    # ip 不够，之后调整
    # Given execute linux command in "mysql8-master2" and contains exception "Access denied for user 'root8' with host '2001:3984:3989:0:0:0:0:20'"
    # """
    # mysql -P9066 -uroot8 -h2001:3984:3989::11 -e "show @@version"
    # """

# shardingUser - %.%.%.%
    Given execute linux command in "mysql-slave1"
    """
    mysql -P8066 -utest1 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql"
    """
    mysql -P8066 -utest1 -h172.100.9.1 -e "select version()"
    """
# shardingUser - 0.0.0.0
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test2' with host '127.0.0.1'"
    """
    mysql -P8066 -utest2 -h127.0.0.1 -e "select version()"
    """
# shardingUser - 0.0.0.0/0
    Given execute linux command in "dble-1"
    """
    mysql -P8066 -utest3 -h127.0.0.1 -e "select version()"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P8066 -utest3 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -utest3 -h172.100.9.1 -e "select version()"
    """
# shardingUser - 172.100.8.%
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test4' with host '172.100.9.1'"
    """
    mysql -P8066 -utest4 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'test4' with host '172.100.9.6'"
    """
    mysql -P8066 -utest4 -h172.100.9.1 -e "select version()"
    """
# shardingUser - 172.100.9.0/24
    Given execute linux command in "dble-1"
    """
    mysql -P8066 -utest5 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-slave2"
    """
    mysql -P8066 -utest5 -h172.100.9.1 -e "select version()"
    """
# shardingUser - 172.100.9.0/30
    Given execute linux command in "dble-1"
    """
    mysql -P8066 -utest6 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql" and contains exception "Access denied for user 'test6' with host '172.100.9.4'"
    """
    mysql -P8066 -utest6 -h172.100.9.1 -e "select version()"
    """
# shardingUser - 2001:3984:3989::0/127
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test7' with host '2001:3984:3989:0:0:0:0:11'"
    """
    mysql -P8066 -utest7 -h2001:3984:3989::11 -e "select version()"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'test7' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P8066 -utest7 -h2001:3984:3989::11 -e "select version()"
    """
# shardingUser - 2001:3984:3989::0/123
    Given execute linux command in "dble-1"
    """
    mysql -P8066 -utest8 -h2001:3984:3989::11 -e "select version()"
    """
    Given execute linux command in "mysql-master2"
    """
    mysql -P8066 -utest8 -h2001:3984:3989::11 -e "select version()"
    """
    # Given execute linux command in "mysql8-master2" and contains exception "Access denied for user 'test8' with host '2001:3984:3989:0:0:0:0:20'"
    # """
    # mysql -P8066 -utest8 -h2001:3984:3989::11 -e "select version()"
    # """

# rwSplitUser - %.%.%.%
    Given execute linux command in "mysql-slave1"
    """
    mysql -P8066 -usplit1 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql"
    """
    mysql -P8066 -usplit1 -h172.100.9.1 -e "select version()"
    """
# rwSplitUser - 0.0.0.0
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'split2' with host '127.0.0.1'"
    """
    mysql -P8066 -usplit2 -h127.0.0.1 -e "select version()"
    """
# rwSplitUser - 0.0.0.0/0
    Given execute linux command in "dble-1"
    """
    mysql -P8066 -usplit3 -h127.0.0.1 -e "select version()"
    """
    Given execute linux command in "dble-1"
    """
    mysql -P8066 -usplit3 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-master1"
    """
    mysql -P8066 -usplit3 -h172.100.9.1 -e "select version()"
    """
# rwSplitUser - 172.100.8.%
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'split4' with host '172.100.9.1'"
    """
    mysql -P8066 -usplit4 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'split4' with host '172.100.9.6'"
    """
    mysql -P8066 -usplit4 -h172.100.9.1 -e "select version()"
    """
# rwSplitUser - 172.100.9.0/24
    Given execute linux command in "dble-1"
    """
    mysql -P8066 -usplit5 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql-slave2"
    """
    mysql -P8066 -usplit5 -h172.100.9.1 -e "select version()"
    """
# rwSplitUser - 172.100.9.0/30
    Given execute linux command in "dble-1"
    """
    mysql -P8066 -usplit6 -h172.100.9.1 -e "select version()"
    """
    Given execute linux command in "mysql" and contains exception "Access denied for user 'split6' with host '172.100.9.4'"
    """
    mysql -P8066 -usplit6 -h172.100.9.1 -e "select version()"
    """
# rwSplitUser - 2001:3984:3989::0/127
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'split7' with host '2001:3984:3989:0:0:0:0:11'"
    """
    mysql -P8066 -usplit7 -h2001:3984:3989::11 -e "select version()"
    """
    Given execute linux command in "mysql-slave2" and contains exception "Access denied for user 'split7' with host '2001:3984:3989:0:0:0:0:16'"
    """
    mysql -P8066 -usplit7 -h2001:3984:3989::11 -e "select version()"
    """
# rwSplitUser - 2001:3984:3989::0/123
    Given execute linux command in "dble-1"
    """
    mysql -P8066 -usplit8 -h2001:3984:3989::11 -e "select version()"
    """
    Given execute linux command in "mysql-master2"
    """
    mysql -P8066 -usplit8 -h2001:3984:3989::11 -e "select version()"
    """
    # Given execute linux command in "mysql8-master2" and contains exception "Access denied for user 'split8' with host '2001:3984:3989:0:0:0:0:20'"
    # """
    # mysql -P8066 -usplit8 -h2001:3984:3989::11 -e "select version()"
    # """