//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"
#include "prepare_util.h"
//usage:
//c_mysql_api.o {centos6|centos7}
//c_mysql_api.o {centos6|centos7} debug

int main(int argc, char *argv[]) {

//    if(argc=3){
//        IS_DEBUG = argc>1 && strcmp(argv[2],"debug")==0;
//	    printf("IS_DEBUG: %d, argc:%d, argv[2]:%s\n", IS_DEBUG, argc, argv[2]);
//    }

	char sys[15] ;
	if(argc>1){
		if (strcmp(argv[1], "centos6")==0){
			sprintf(sys, "%s", "centos6");
			printf("arg os is: %s\n",argv[1]);
		}else if (strcmp(argv[1], "centos7")==0){
			sprintf(sys, "%s", "centos7");
			printf("arg os is: %s\n",argv[1]);
		}else{
			printf("arg os err! support only centos6 or centos7\n");
			exit(1);
		}
	}else{
		sprintf(sys, "%s", "centos7");
	}

    config("../../sys.config", sys);
    MYSQL* conn = getConn();

    //failure
	//case_mysql_change_user(conn);
	//case_mysql_real_query(conn);
	//case_mysql_reset_connection(conn);
	//case_mysql_session_track_get_first(conn);
	//case_mysql_set_server_option(conn);
	//case_mysql_stat(conn);
	//passs
	case_mysql_field_count(conn);
	case_mysql_get_host_info(conn);
	case_mysql_info(conn);
	case_mysql_insert_id(conn);
	case_mysql_list_dbs(conn);
	case_mysql_options4(conn);
	case_mysql_real_connect(conn);
	case_mysql_real_escape_string(conn);
	case_mysql_rollback(conn);
	case_mysql_row_seek(conn);
	case_mysql_select_db(conn);
	case_mysql_set_character_set(conn);
	case_mysql_use_result(conn);
	//error
	//case_mysql_hex_string(conn);

	//case_mysql_set_local_infile_handler(); ?
	//case_mysql_sqlstate(conn); ?
	//case_mysql_thread_id(); ?

	//case_null_in_sql(); ?

	mysql_close(conn);

	//not test
	//wPrepareTest();
	//rPrepareTest();

	cout << "!!!Test Over!!!" << endl;
	return 0;
}
