Feature: #reload @@config_all/rollback @@config
  Scenario: #
    Then Delete the "mytestA" schema in schema.xml
    Given Add a "mytestA" schema in schema.xml
    Given Add a table consisting of "mytestA" in schema.xml
    """
    "name":"test1","dataNode":"dn1,dn2,dn3,dn4","rule":"hash-four"
    """
    Given Add a table consisting of "mytestA" in schema.xml
    """
    "name":"test2","dataNode":"dn1,dn2,dn3,dn4","rule":"hash-four"
    """
    Given Add a table consisting of "mytestA" in schema.xml
    """
    "name":"sbtestA","dataNode":"dn1,dn2,dn3,dn4","rule":"hash-four"
    """
    Then Delete the "mytestB" schema in schema.xml
    Given Add a "mytestB" schema in schema.xml
    Given Add a table consisting of "mytestB" in schema.xml
    """
    "name":"test1","dataNode":"dn5,dn6,dn7,dn8","rule":"hash-four"
    """
    Given Add a table consisting of "mytestB" in schema.xml
    """
    "name":"test2","dataNode":"dn5,dn6,dn7,dn8","rule":"hash-four"
    """
    Given Add a table consisting of "mytestB" in schema.xml
    """
    "name":"sbtestB","dataNode":"dn5,dn6,dn7,dn8","rule":"hash-four"
    """


