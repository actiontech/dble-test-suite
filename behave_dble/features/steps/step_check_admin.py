# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
from behave import *
from .step_reload import get_admin_conn


def destroy_share_n_conn(context):
    for i in range(1,10):
        dble_conn_name = "share_conn_{0}".format(i)
        if hasattr(context, dble_conn_name):
            conn_dble = getattr(context, dble_conn_name)
            conn_dble.close()
            delattr(context, dble_conn_name)

def do_admin_query(context, line_nu, sql):
    sql = sql.strip()
    result = None
    if len(sql) > 0:
        context.logger.info("execute admin sql line:{0}, sql:{1}".format(line_nu, sql))
        result, err = context.conn_admin.query(sql)
        context.logger.info("admin sql err:{1}".format(result, err))

        if len(sql) > 1000:sql = "{0}...{1}".format(sql[0:300], sql[-50:])

        if err is None:
            with open(context.cur_pass_log, 'a') as fpT:
                fpT.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(line_nu, sql, context.sql_file))
                context.logger.info("result is: {0}".format(result))
                fpT.writelines(str(result))
        else:
            with open(context.cur_fail_log, 'a') as fpF:
                fpF.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(line_nu, sql, context.sql_file))
                fpF.writelines(str(result))
                fpF.writelines(str(err))

    return result

@Then('execute sql in "{filename}" to check manager work fine')
def step_impl(context, filename):
    context.sql_file = filename
    context.execute_steps(u'Given init read-write-split data')
    filepath = "sqls/{0}".format(filename)
    sql = ''
    line_nu = 0
    if (not hasattr(context, "conn_dble")) or context.conn_dble is None:
        context.conn_admin = get_admin_conn(context)

    with open(filepath) as fp:
        lines = fp.readlines()
        context.linenu = 0
        for line in lines:
            line_nu += 1
            context.logger.info("**************************************************")
            if line.startswith('#'):
                context.logger.info("jump comment line, conntions to exec sql next")
                continue
            sql = sql + line.strip() + "\n"
            do_admin_query(context, line_nu, sql)

            sql = ''




