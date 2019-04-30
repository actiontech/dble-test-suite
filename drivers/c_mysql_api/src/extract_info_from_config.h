/*
 * exact_info_from_config.h
 *
 *  Created on: 2017年10月16日
 *      Author: apple
 */

#ifndef EXTRACT_INFO_FROM_CONFIG_H_
#define EXTRACT_INFO_FROM_CONFIG_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <errno.h>
#include <ctype.h>
#include <fstream>

#define KEYVALLEN 100

extern char HOST_DBLE[50];
extern char HOST_MASTER[50];
//extern char Host_Slave1[50];
//extern char Host_Slave2[50];
//static String[] mysql_hosts = new String[4];
extern char ADMIN[100];
extern char ADMIN_PASSWD[100];

extern char TEST_USER[100];
extern char TEST_USER_PASSWD[100];
extern char TEST_DB[50];
extern unsigned int DBLE_PORT;
extern unsigned int DBLE_ADMIN_PORT;

//static unsigned int MYSQL_PORT = 3306;

//extern char SSH_USER[50];
//extern char SSH_PASSWORD[50];
//
//extern char MYSQL_INSTALL_PATH[150];
//extern char UPROXY_INSTALL_PATH[150];
//extern char ROOT_PATH[50];
extern char SQLS_CONFIG[100];

#define TEST_TABLE "sharding_4_t1"
#define DROP_SAMPLE_TABLE "DROP TABLE IF EXISTS " TEST_TABLE
#define CREATE_SAMPLE_TABLE "CREATE TABLE " TEST_TABLE "(id INT,\
                                                 col2 VARCHAR(40),\
                                                 col3 SMALLINT,\
                                                 col4 TIMESTAMP)"

extern int IS_DEBUG;

void config(char *profile, char *sys);
#endif /* EXTRACT_INFO_FROM_CONFIG_H_ */
