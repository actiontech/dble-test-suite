from hamcrest import *
# no use at present -- zhj
class CheckReload:
    def __init__(self, conn, context):
        self._conn = conn
        self._context = context

    def check_schema(self, schema):
        sql = "show databases"
        res, err = self._conn.execute_sql(sql)
        assert_that(res, contains_string(schema))
    def check_table(self, table, type):
        sql = "create table {0}(id int)".format(table)
        res, err = self._conn.execute_sql(sql)
        assert_that(err, is_(""))
        sql = "show full tables"
        res, err = self._conn.execute_sql(sql)
        for row in res:
            if row[0] == table:
                assert_that(type, contains_string(row[1]))