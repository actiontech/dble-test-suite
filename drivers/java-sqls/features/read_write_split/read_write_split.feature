Feature: read-write-split work fine, load balance of read work right

# 前置：
#   1.按照/* uproxy_dest_expect:M/S/CS/CM */这种格式预定义好sql期望被发往哪里
#   2.将直连发往单主的sql执行结果与通过uproxy发送到一主二从的服务器得到的结果进行对比
# Scenario Outline:#1, #2
#   1.比对sql语句的执行结果:
#     a.sql执行且结果相同或允许结果不同     result/success_sql_file
#     b.sql执行结果相同但有报错且一致       result/warn_sql_file
#     c.sql执行结果相同但有报错且不一致     result/serious_warn_sql_file
#     d.sql执行结果不同                    result/fail_sql_file
#   2.被发往从的语句发到了哪个从上进行计数统计，结果保存在 result/balance.log
# Scenario:#2 验证uproxy对共享锁(lock in share mode)和排它锁(for update)的支持

    @smoke
    Scenario Outline:#1 check read-write-split work fine and slaves load balance
        Then execute sql in "<filename>" to check read-write-split work fine and log dest slave
        Given clear dirty data yield by sql

        Examples:Types
          | filename                          |
          | select.sql                     |
