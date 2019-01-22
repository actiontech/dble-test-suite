# Created by zhaohongjie at 2019/1/16
#SET NAMES {'charset_name'
#    [COLLATE 'collation_name'] | DEFAULT}
#!share_conn
set character set ascii
select @@character_set_client
select @@character_set_results
set character set DEFAULT
select @@character_set_client
select @@character_set_results
set charset ascii
select @@character_set_client
select @@character_set_results
set charset DEFAULT
select @@character_set_client
select @@character_set_results
set names default
select @@character_set_client
select @@character_set_results
select @@character_set_connection
set names 'ascii' collate 'ascii_general_ci'
select @@character_set_client
select @@character_set_results
select @@character_set_connection