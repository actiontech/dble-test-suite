#include "client_fw.c"

static void client_query_1();
static void client_query_2();

int main() {
    char *server = "172.100.0.2";
    unsigned int port = 8066;
    char *user = "test";
    char *password = "test";
    char *database = "schema1";

    mysql = mysql_init(NULL);
    if(!mysql_real_connect(mysql, server, user, password, database, port, NULL, CLIENT_DEPRECATE_EOF))
    {
        printf("Error connecting to database: %s\n", mysql_error(mysql));
    }
    else
    {
        printf("Connected....\n");
    }

    client_query_1();
//    client_query_2();

    mysql_close(mysql);
    return 0;
}

static void client_query_1()
{
    int rc;
    MYSQL_RES *result;
    my_bool autoCommit;
    myheader("client_query");

    rc= mysql_query(mysql, "DROP TABLE IF EXISTS aly_test");
    myquery(rc);

    rc= mysql_query(mysql, "CREATE TABLE aly_test(id int, name varchar(20))");
    myquery(rc);

    autoCommit = mysql_autocommit(mysql, 0);
    printf("autocommit %d \n", autoCommit);

    rc= mysql_query(mysql, "INSERT INTO aly_test(id,name) VALUES(1,'mysql')");
    myquery(rc);
    if (rc)
    {
     fprintf(stderr,"Failed to mysql_query. Error:%s\n",
                mysql_error(mysql));
     }else{
        result = mysql_store_result(mysql);
        if (result)
        {
            num_fields = mysql_num_fields(result);
        }
        else{
            if(mysql_field_count(mysql) == 0)
            {
                num_rows = mysql_affected_rows(mysql);
            }
            else
            {
                fprintf(stderr,"Error: %s\n",mysql_error(mysql));
            }
        }
     }


    printf("%ld products updated \n", (long) mysql_affected_rows(mysql));

    autoCommit = mysql_autocommit(mysql, 1);
    printf("autocommit %d \n", autoCommit);

    if (mysql_change_user(mysql, "test1", "111111", ""))
    {
        fprintf(stderr, "Failed to change user.  Error: %s\n",
               mysql_error(mysql));
    }else{
        printf("change user success!\n");
    }

    myquery(mysql_query(mysql, "drop table aly_test"));
}

static void client_query_2()
{
    MYSQL_RES  *res;
    MYSQL_ROW  row;
    MYSQL_FIELD  *fields;
    int t;
    unsigned int  num_fields;
    unsigned int  i;

    t = mysql_query(mysql, "select user, host from mysql.user");
    if(t)
    {
        printf("Error making query: %s\n", mysql_error(mysql));
    }
    else
    {
        res=mysql_store_result(mysql);  

        num_fields = mysql_num_fields(res);             //获取查询结果中，字段的个数  
        fields = mysql_fetch_fields(res);               //获取查询结果中，各个字段的名字  
        for(i = 0; i < num_fields;i++)  
        {  
                 printf("result field %u：  %s\n",i,fields[i].name);  
        }  
          
        //print result lines           
        printf("Number of rows %lu\n",(unsigned long)mysql_num_rows(res));  
        if((unsigned long)mysql_num_rows(res)>1024)  
        {     
            printf("MAXIPLIST is not enough！\n");  
            return;  
        }         
  
        while(row=mysql_fetch_row(res))  
        {                  
            printf("user is: %-30s   host is: %s",row[0],row[1]);   
            printf("\n");  
        }  
        mysql_free_result(res);
    }
}