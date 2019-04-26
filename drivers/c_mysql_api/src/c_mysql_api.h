/*
 * c_mysql_api.h
 *
 *  Created on: 2017年10月16日
 *      Author: apple
 */

#ifndef C_MYSQL_API_H_
#define C_MYSQL_API_H_

#include "mysql_api_test_util.h"

void case_mysql_change_user(MYSQL* conn);
void case_mysql_field_count(MYSQL* mysql);
void case_mysql_get_host_info(MYSQL* mysql);
void case_mysql_insert_id(MYSQL* mysql);
void case_mysql_list_dbs(MYSQL *mysql);
void case_mysql_options4(MYSQL* conn);
void case_mysql_real_connect(MYSQL* conn);
void case_mysql_real_escape_string(MYSQL* mysql);
void case_mysql_real_query(MYSQL* conn);
void case_mysql_reset_connection(MYSQL* conn);
void case_mysql_rollback(MYSQL* conn);
void case_mysql_row_seek(MYSQL* conn);
void case_mysql_set_character_set(MYSQL* mysql);
void case_mysql_select_db(MYSQL* conn);
void case_mysql_session_track_get_first(MYSQL* mysql);
int case_mysql_set_local_infile_handler();
void case_mysql_set_server_option(MYSQL* conn);
void case_mysql_sqlstate(MYSQL* conn);
void case_mysql_stat(MYSQL* conn);
void case_mysql_thread_id();
void case_mysql_use_result(MYSQL* mysql);
void case_null_in_sql();

#endif /* C_MYSQL_API_H_ */
