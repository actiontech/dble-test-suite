#include<mysql.h>
#include<stdio.h>

static my_bool opt_silent= 0;

static MYSQL *mysql=0;
static unsigned int test_count= 0;
static unsigned int iter_count= 0;
static unsigned int opt_count= 0;

#define myheader(str)                                                   \
//DBUG_PRINT("test", ("name: %s", str));                                  \
 if (opt_silent < 2)                                                    \
 {                                                                      \
   fprintf(stdout, "\n\n#####################################\n");      \
   fprintf(stdout, "%u of (%u/%u): %s", test_count++, iter_count,       \
   opt_count, str);                                                     \
   fprintf(stdout, "  \n#####################################\n");      \
 }

/* Print the error message */

#define DIE_UNLESS(expr)                                        \
((void) ((expr) ? 0 : (die(__FILE__, __LINE__, #expr), 0)))

static void die(const char *file, int line, const char *expr)
{
 fflush(stdout);
 fprintf(stderr, "%s:%d: check failed: '%s'\n", file, line, expr);
 fflush(stderr);
 exit(1);
}

static void print_error(MYSQL *l_mysql, const char *msg)
{
 if (!opt_silent)
 {
   if (l_mysql && mysql_errno(l_mysql))
   {
     if (l_mysql->server_version)
     fprintf(stdout, "\n [MySQL-%s]", l_mysql->server_version);
     else
     fprintf(stdout, "\n [MySQL]");
     fprintf(stdout, "[%d] %s\n", mysql_errno(l_mysql), mysql_error(l_mysql));
   }
   else if (msg)
   fprintf(stderr, " [MySQL] %s\n", msg);
 }
}

#define myerror(msg) print_error(mysql,msg)

#define myquery(RES){ int r= (RES);  if (r) myerror(NULL); DIE_UNLESS(r == 0);}  