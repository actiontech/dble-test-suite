# Created by maofei at 2019/4/10
Feature: # dryrun test

  Scenario: #type value "default" in schema.xml  from issue:1109  #1
    Given add xml segment to node with attribute "{'tag':'schema'}" in "schema.xml"
    """
       <table dataNode="dn1,dn2,dn3,dn4" type="default" name="test" rule="hash-four" />
    """
    Then execute sql in "dble-1" in "admin" mode
    | user  | passwd    | conn   | toClose | sql          | expect                                                                            | db  |
    | root  | 111111    | conn_0 | True    | dryrun       |  hasNoStr{Table[test] attribute type sharding in schema.xml is illegal} |     |
    Given add xml segment to node with attribute "{'tag':'schema'}" in "schema.xml"
    """
       <table dataNode="dn1,dn2,dn3,dn4" type="defau" name="test" rule="hash-four" />
    """
    Then execute sql in "dble-1" in "admin" mode
    | user  | passwd    | conn   | toClose | sql          | expect                                                                                          | db  |
    | root  | 111111    | conn_0 | True    | dryrun       |  hasStr{attribute type value 'defau' in schema.xml is illegal, use default replaced} |     |
