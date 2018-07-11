import logging
import re
from behave import *
from hamcrest import *
from step_reload import get_admin_conn, get_dble_conn
from lib.generate_util import *

LOGGER = logging.getLogger('steps.install')

@Then('get limited results')
def get_limit_result(context):
    num = int(context.text)
    conn = get_dble_conn(context)

    select_sql="select * from test_table"
    res, errMsg = conn.query(select_sql)
    conn.close()

    LOGGER.info("the length of limit result is:{0}".format(len(res)))

    assert_that(len(res),equal_to(num))