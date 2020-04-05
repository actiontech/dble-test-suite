# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature:  insert into values (),(),()... to verify the max rows can be inserted

    @skip
    Scenario:
        Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
        """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" cacheKey="id" rule="fixed_string_rule" />
        """
        Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
        """
        <tableRule name="fixed_string_rule">
            <rule>
                <columns>c</columns>
                <algorithm>fixed_uniform_string</algorithm>
            </rule>
        </tableRule>
        <function name="fixed_uniform_string" class="StringHash">
            <property name="partitionCount">4</property>
            <property name="partitionLength">256</property>
            <property name="hashSlice">0:4</property>
        </function>
        """
        Then execute admin cmd "reload @@config_all"
        When execute sql in "dble-1" in "user" mode
          | sql                             | db      |
          | drop table if exists test_table | schema1 |
          | create table test_table(id int,k int, c char(10), pad char(60) primary key (id), key k_1 (k)) | schema1 |
        Then insert "5000" rows at one time

