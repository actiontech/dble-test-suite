# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/9/23

Feature: check data with show @@data_distribution where table ='schema.table'
@skip_restart
  Scenario: show @@data_distribution where table ='schema.table'  #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sbtest1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="k" />
    </schema>
    """
    Then execute admin cmd "reload @@config"



