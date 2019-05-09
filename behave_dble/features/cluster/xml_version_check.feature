# Created by WuJinling at 2019/3/6
Feature: test "check xml version warning message in dble.log and dryrun"
  # details please refer to github issue #986
  Scenario: check xml version warning  message in dryrun and dble.log #1
    #Given add xml segment to node with attribute "{'tag':'dble',{"version":"9.9.9.0"}}" in "server.xml"
    Given add attribute "{"version":"9.9.9.0"}" to rootnode in "server.xml"
    Given add attribute "{"version":"9.9.9.9"}" to rootnode in "rule.xml"
    Then execute admin cmd "reload @@config_all"
    Given sleep "2" seconds
    Then get resultset of admin cmd "dryrun" named "dryrun_rs"
    Then check resultset "dryrun_rs" has lines with following column values
      | TYPE-0 | LEVEL-1 | DETAIL-2                                                                                                                                                    |
      | Xml    | WARNING | The server-version is ${version},but the server.xml version is 9.9.9.0.There may be some incompatible config between two versions,please check it              |
      | Xml    | WARNING | The server-version is ${version},but the schema.xml version is 2.18.12.0 or earlier.There may be some incompatible config between two versions,please check it |
    And check "dble.log" in "dble-1" has the warnings
      | TYPE-0 | LEVEL-1 | DETAIL-2                                                                                                                                                    |
      | Xml    | WARNING | The server-version is ${version},but the server.xml version is 9.9.9.0.There may be some incompatible config between two versions,please check it              |
      | Xml    | WARNING | The server-version is ${version},but the schema.xml version is 2.18.12.0 or earlier.There may be some incompatible config between two versions,please check it |
    Then check following " " exist in file "/opt/dble/conf/rule.xml" in "dble-2"
      """
      version="9.9.9.9"
     """
    Then check following " " exist in file "/opt/dble/conf/server.xml" in "dble-2"
      """
      version="9.9.9.0"
     """
    Then check following " " exist in file "/opt/dble/conf/rule.xml" in "dble-3"
      """
      version="9.9.9.9"
     """
    Then check following " " exist in file "/opt/dble/conf/server.xml" in "dble-3"
      """
      version="9.9.9.0"
     """