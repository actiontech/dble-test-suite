Feature: dataNode's lettercase is insensitive, that is should not affected by lower_case_table_names

  @regression
  Scenario:#1. dataNode's lettercase is insensitive, but reference to the dataNode name must consistent
    Given delete the following xml segment
    |file        | parent          | child               |
    |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
    |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
    |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="DN1" name="mytest" sqlMaxLimit="100">
      <table dataNode="DN1,dn3" name="test1" type="global" />
	</schema>
	<dataNode dataHost="172.100.9.5" database="db1" name="DN1" />
	<dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
    """
    Given restart mysql in "mysql-master1" with options
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 0
    """
    Given Restart dble in "dble-1" success
    Given restart mysql in "mysql-master1" with options
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
    Given Restart dble in "dble-1" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
     <schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
       <table dataNode="dn1,dn3" name="test" type="global" />
	 </schema>
    """
    Then restart dble in "dble-1" failed for
    """
    dataNode 'DN1' is not found
    """
    Given restart mysql in "mysql-master1" with options
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 0
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	<dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
    """
    Given Restart dble in "dble-1" success