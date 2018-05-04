Feature:  insert into values (),(),()... to verify the max rows can be inserted

    Scenario:
        Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
        """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" primaryKey="id" autoIncrement="true" rule="fixed_string_rule" />
        """
        Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
        """
        <property name="sequnceHandlerType">0</property>
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
        Given create table for insert
        Then insert "100" rows at one time

