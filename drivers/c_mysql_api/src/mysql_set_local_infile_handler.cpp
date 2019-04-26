//============================================================================
// Name        : c_mysql_api.cpp
// Author      : zhaohongjie
// Version     :
// Copyright   : reserved
// Description : Hello World in C++, Ansi-style
//============================================================================
#include "c_mysql_api.h"


/* configure server access here,
   needs the following table in the
   given MYSQL_DB:

   CREATE TABLE local_infile_test(
     id  INT,
     msg VARCHAR(100)
   ) ENGINE=myisam;

*/

/* config part ends here */

/* standard C headers */
#include <time.h>

/* MySQL specific headers */
#include <errmsg.h>

/* init() handler

   void ** instance_data -> put pointer to allocated instance data here
   const char filename   -> filename as given in LOAD DATA LOCAL statement
   void * handler_data   -> as given as last parameter to mysql_set_local_infile_handler()

   return int: 0 on success, non-zero on errors
*/
int local_infile_init(void **instance_data, const char *filename, void *handler_data)
{
  int *line_counter;

  printf("    local_infile_init '%s' ('%s')\n", filename, (char *)handler_data);

  line_counter = static_cast<int *>( malloc(sizeof(int)));
  if (NULL == line_counter) {
    fprintf(stderr, "malloc failed in local_infile_init()\n");
    *instance_data = NULL;
    return 1;
  }

  *line_counter = 0;
  *instance_data = (void *)line_counter;

  return 0;
}

/* read() handler

   void *instance_data -> as set in init()
   char *buf           -> store read data here
   unsigned int buflen -> but not more than this number of bytes

   return int:    number of bytes stored in buf
               OR 0 on end of data
               OR negative number on errors
*/
int local_infile_read(void *instance_data, char *buf, unsigned int buf_len)
{
  int *line_counter = (int *)instance_data;

  printf("    local_infile_read line %d (buf_len: %u)\n", ++(*line_counter), buf_len);

  switch (*line_counter) {
  case 1:
    strcpy(buf, "23,bar\n"); /* we should check that we're not
                                exceeding buf_len, skipped for
                                keeping the example short here
                             */
    break;

  case 2:
    strcpy(buf, "42,bar\n");
    break;

  default:
    {
//      switch (time(NULL) % 2) {
//        /* 50% chance of clean exit
//           or triggering the error handler */
//      case 0:
//        printf("no more data\n");
//        return 0;
//      case 1:
        printf("    forcing error\n");
        return -1;
//      }
    }
  }

  return strlen(buf);
}

/* end() handler

   void * instance_data -> as set in init() handler
*/
void local_infile_end(void *instance_data)
{
  printf("    local_infile_end\n");

  if (instance_data) {
    free(instance_data);
  }
}

/* error() handler

   void * instance_data -> as set in init() handler
   char * error_msg     -> store \0 terminated textual error message here
   unsigned int msg_len -> but no more than this many bytes, including \0

   return int: numeric error code
*/
int local_infile_error(void *instance_data, char *error_msg, unsigned int error_msg_len)
{
  printf("    local_infile_error\n");

  /* instance data uninitialized -> init failed */
  if (NULL == instance_data) {
    fprintf(stderr, "allocation failure in init()\n");
    strcpy(error_msg, "allocation failure in init()");
    return CR_OUT_OF_MEMORY;
  }

  /* otherwise: read failed */
  sprintf(error_msg,
          "    read() error on reading line %d",
          *((int *)instance_data));

  return CR_UNKNOWN_ERROR;
}



int case_mysql_set_local_infile_handler()
{
	printf("==>mysql_set_local_infile_handler test suites\n");

    MYSQL *conn = NULL;
    int opt_local_infile = 1;
    int stat;

    /* initialize client connection handle */
    conn = mysql_init(conn);
    if (!conn) {
        puts("Init faild, out of memory?");
        return EXIT_FAILURE;
    }

    /* enable local infile handling */
    mysql_options(conn, MYSQL_OPT_LOCAL_INFILE, (char*) &opt_local_infile);

    if(IS_DEBUG){
        mysql_real_connect(conn, HOST_MASTER, TEST_USER, TEST_USER_PASSWD, TEST_DB, MYSQL_PORT, NULL, CLIENT_DEPRECATE_EOF);
    }else{
        mysql_real_connect(conn, HOST_DBLE, TEST_USER, TEST_USER_PASSWD, TEST_DB, DBLE_PORT,NULL, CLIENT_DEPRECATE_EOF);
	}
    if (conn == NULL) {
        printf("Error connecting to database: %s\n", mysql_error(conn));
        exit(1);
    }

    /* register our own infile handler */
    mysql_set_local_infile_handler(conn,
                                 local_infile_init,
                                 local_infile_read,
                                 local_infile_end,
                                 local_infile_error,
                                 NULL);

	myquery(conn, "DROP TABLE if exists local_infile_test");
	myquery(conn, "CREATE TABLE local_infile_test(id  INT,msg VARCHAR(100));");
    /* now trigger infile handling */
    stat = mysql_query(conn, "LOAD DATA LOCAL INFILE 'infile_source.txt' "
                            "     INTO TABLE local_infile_test "
                            "   FIELDS TERMINATED BY ','");
    if (stat) {
        /* errno and error should be those set by local_infile_error() */
        fprintf(stderr, "    pass! after mysql_set_local_infile_handler, query 'load data local infile ...' ,stat: %d %s\n", mysql_errno(conn), mysql_error(conn));
    }else{
    		printf("expect load data infile ... failed! \n");
    		exit(1);
    }

	/* cleanup */
	mysql_close(conn);
	return 1;
}
