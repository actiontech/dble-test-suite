#执行sql对比相关的steps
from behave import *
from steps.ObjectFactory import ObjectFactory
from steps.PostQueryCheck import PostQueryCheck
from steps.PreQueryPrepare import PreQueryPrepare
from steps.QueryMeta import QueryMeta
import logging,time,os
import subprocess,re


logger=logging.getLogger("root")


@Given('execute sqls in file "{sql_file}"')
def step_impl(context,sql_file):
    logger.debug("*"*30)
    logger.debug(sql_file)
    context.sql_file=sql_file
    filepath='sqls/'+sql_file
    context.compare=False
<<<<<<< HEAD
    create_logs(context)
    #sql_result\xxx_template or sql_result\xxx
=======
    create_logs(context,'_pass')
    #sql_result\xxx_template_pass or sql_result\xxx_pass
    create_logs(context,'_err')
    #sql_result\xxx_template_err or sql_result\xxx_err
>>>>>>> 4068dd40576e96ef79842f053fda0edab74ba0c6
    #读sql然后执行
    read_and_execute(context,filepath)
    if context.compare:
        compare_result(context)

<<<<<<< HEAD
def create_logs(context):
=======
def create_logs(context,name):
>>>>>>> 4068dd40576e96ef79842f053fda0edab74ba0c6
    #检查之前是否有结果记录集 没有就生成 有就建立临时对比项 有临时对比项就覆盖之前记录
    path=os.getcwd()
    context.model_result_path=path+'/sql_results/'+context.sql_file.split(".")[0]
    #sql_result\xxx
<<<<<<< HEAD
    if os.path.exists(context.model_result_path+'.log'):
        context.compare=True
        context.result_path=context.model_result_path+'_template'
        #sql_result\xxx_template
    else:
        context.result_path=context.model_result_path
    logger.debug(context.sql_file)
    if context.sql_file.find("/")!= -1:#处理写的sql名字里有/的情况
        subdir=path+'/sql_results/'+context.sql_file.split('/')[0]
        logger.debug(subdir)
        if not os.path.exists(subdir):
            os.mkdir(subdir)
    with open (context.result_path+'.log','w') as f:
=======
    if os.path.exists(context.model_result_path+name+'.log'):
        context.result_path=context.model_result_path.split(".")[0]+'_template'
        #sql_result\xxx_template
    else:
        context.result_path=context.model_result_path

    with open (context.result_path+name+'.log','w') as f:
>>>>>>> 4068dd40576e96ef79842f053fda0edab74ba0c6
        f.close()

def read_and_execute(context,filepath):
    with open (filepath,'r') as file:
        global lines
        lines=file.readlines()
<<<<<<< HEAD
        if lines[0].find("default_db")!= -1:
            context.db=lines[0].strip().split(":")[1]#如果写db就放在第一行
        else:
            context.db="schema1"
=======
        context.db=lines[0].strip().split(":")[1]#第一行要记得写一下db
>>>>>>> 4068dd40576e96ef79842f053fda0edab74ba0c6
        num=1
        #从第二行开始读
        while num <len(lines):#行标<行数的时候（行标 0 1 2 行数 1 2 3）
            sql,num=get_sql(context,num)#获取要执行的sql和下一行的行标
            logger.debug("now executing sql "+sql+" in line "+str(num))
            res_dble=execute_sql(context,sql,"dble")#在dble执行当前句
            res_mysql=execute_sql(context,sql,"mysql")#在mysql执行当前句
            write_result(context,res_dble,res_mysql,num)#记录结果

def get_sql(context,num):
    sql=''
<<<<<<< HEAD
    context.toClose = "False"
    if num>=len(lines):#当最后一行是#xxxx的时候会再次进入到这个方法中..需要跳出
        return ['show tables',num]
    if lines[num].strip()=='':
        num=num+1
        return get_sql(context,num)
    if lines[num].strip().startswith('#!multiline'):#多行sql
        while lines[num].find("#end multiline") != -1:#去找多行结束的flag
            sql=lines[num].strip()+sql+ "\n"
            num=num+1
    elif lines[num].strip().startswith("#!share_conn"):#share_conn 用同一个连接
        context.conn_id = re.search('share_conn_?\d*', lines[num])
        num=num+1
        return get_sql(context,num)
    # elif lines[num].strip().startswith("#end"):#关闭当前的连接 uproxy中的sql的特有写法 但其实uproxy代码里没有相关处理
    #     context.toClose = "True"
    #     context.conn_id
    #     num=num+1
    #     return get_sql(context,num)
    elif lines[num].strip().startswith("#"):#其他情况当注释
        num=num+1
        return get_sql(context,num)
    else:
        sql=lines[num].strip()
        context.toClose = "False"
        if not hasattr(context,"conn_id"):
            context.conn_id=1
    if num==len(lines)-1:#最后一行则关闭连接
=======
    if lines[num].startswith("##"):#注释
        context.toClose = "True"
        num=num+1
        return get_sql(num)
    elif lines[num].startswith('#!multiline'):#多行sql
        while lines[num].find("#end multiline") != -1:#去找多行结束的flag
            sql=lines[num]+sql+ "\n"
            num=num+1
        context.toClose = "True"
    elif lines[num].startswith("#!share_conn"):
        context.toClose = "True"
        context.conn_id = re.search('share_conn_?\d*', lines[num])
    else:
        sql=lines[num]
        context.toClose = "False"
        if not hasattr(context,"conn_id"):
            context.conn_id=1
    if num==len(lines)-1:
>>>>>>> 4068dd40576e96ef79842f053fda0edab74ba0c6
        context.toClose = "True"
    next_num=num+1
    return sql,next_num

def execute_sql(context,sql,type):
    if type=="dble":
        logger.debug("get into executing dble")
        print("get into executing dble")
        res,err=do_execute(("dble-1"),{"sql":sql,"db":context.db,"toClose":context.toClose,"conn":context.conn_id},"user")
<<<<<<< HEAD
        logger.debug(res)
        logger.debug(err)
        print(res,err)
    elif type=="mysql":
        #只在单主的那个mysql上执行
        logger.debug("get into executing mysql")
        print("get into executing mysql")
        res,err=do_execute(("mysql-master1"),{"sql":sql,"db":"test","toClose":context.toClose,"conn":context.conn_id},"mysql")
        logger.debug(res)
        logger.debug(err)
=======
        logger.debug(res,err)
        print(res,err)
    elif type=="mysql":
        #只在单主的那个mysql上执行
        print("get into executing mysql")
        res,err=do_execute(("mysql-master1"),{"sql":sql,"db":"test","toClose":context.toClose,"conn":context.conn_id},"mysql")
>>>>>>> 4068dd40576e96ef79842f053fda0edab74ba0c6
        print(res,err)
    result=[res,err,sql]
    return result

def do_execute(host_name, info_dic, mode):
    if mode in ["admin", "user"]:
        obj = ObjectFactory.create_dble_object(host_name)
        query_meta = QueryMeta(info_dic, mode, obj._dble_meta)
    else:
        obj = ObjectFactory.create_mysql_object(host_name)
        query_meta = QueryMeta(info_dic, mode, obj._mysql_meta)

    res, err,time_cost = obj.do_execute_query(query_meta)
    return res, err

def write_result(context,res_dble,res_mysql,num):
    res = [res_dble[0],res_mysql[0]]
    err = [res_dble[1],res_mysql[1]]
    sql = res_dble[2]
<<<<<<< HEAD
    write_log(context,res,err,sql,num)

    # if res[0]==res[1] and err[0]==err[1]:
    #     logger.debug("result the same")

    # elif err[0]==err[1]==None:
    #     write_log(context,res,err,sql,id,'_pass')#通过但结果不一样
    #     context.compare="True"
    # else:
    #     write_log(context,res,err,sql,id,'_err')#有报错且结果也不一样
    #     context.compare="True"

def write_log(context,res,err,sql,id):
    with open(context.result_path+'.log','a') as file:
        file.writelines('当前文件中执行ID为：'+str(id)+'的sql：'+'\''+sql+'\''+'\n')
        file.writelines('dble_res:{0}\n'.format(res[0]))
        file.writelines('mysql_res:{0}\n'.format(res[1]))
        file.writelines('dble_err:{0}\n'.format(err[0]))
        file.writelines('mysql_err:{0}\n'.format(err[1]))
=======
    id = num-1
    if res[0]==res[1] and err[0]==err[1]:
        logger.debug("result the same")
        return
    elif err[0]==err[1]==None:
        write_log(context,res,err,sql,id,'_pass')#通过但结果不一样
        context.compare="True"
    else:
        write_log(context,res,err,sql,id,'_err')#有报错且结果也不一样
        context.compare="True"

def write_log(context,res,err,sql,id,name):
    with open(context.result_path+name+'.log','a') as file:
        file.writelines('当前文件中执行ID为：'+str(id)+'的sql：'+'\''+sql+'\''+'\n')
        file.writelines('dble_res:{0}\n'.format(res[0]))
        file.writelines('mysql_res:{0}\n'.format(res[1]))
        if name=='_err':
            file.writelines('dble_err:{0}\n'.format(err[0]))
            file.writelines('mysql_err:{0}\n'.format(err[1]))
>>>>>>> 4068dd40576e96ef79842f053fda0edab74ba0c6
        file.close()

def compare_result(context):
    #对比产出的result的log文件
    #context.model_result_path    context.result_path    
    ##sql_result\xxx sql_result\xxx_template
<<<<<<< HEAD
    #此处的逻辑是每跑完一个.sql文件就对比一次
    try:
        logger.debug("comparing......")
        out_bytes = subprocess.check_output(['bash', 'compare_result.sh', context.model_result_path+'.log', context.result_path+'.log'])
=======

    #此处的逻辑是每跑完一个.sql文件就对比一次
    try:
        out_bytes = subprocess.check_output(['bash', 'compare_result.sh', context.model_result_path+'_err.log', context.result_path+'_err.log'])
        out_bytes = subprocess.check_output(['bash', 'compare_result.sh', context.model_result_path+'_pass.log', context.result_path+'_pass.log'])
>>>>>>> 4068dd40576e96ef79842f053fda0edab74ba0c6
    except subprocess.CalledProcessError as e:
        out_bytes = e.output  # Output generated before error
        out_text = out_bytes.decode('utf-8')
        assert False, "result is different with standard, {0}".format(out_text)
    finally:
<<<<<<< HEAD
        logger.info(out_bytes.decode('utf-8'))
=======
        context.logger.info(out_bytes.decode('utf-8'))
>>>>>>> 4068dd40576e96ef79842f053fda0edab74ba0c6


    #difflib.SequenceMatcher()

#using for enviroment_after_all 
def execute_sql_in_host(host_name, info_dic, mode="mysql"):
    if mode in ["admin", "user"]:  # query to dble
        obj = ObjectFactory.create_dble_object(host_name)
        query_meta = QueryMeta(info_dic, mode, obj._dble_meta)
    else:
        obj = ObjectFactory.create_mysql_object(host_name)
        query_meta = QueryMeta(info_dic, mode, obj._mysql_meta)

    pre_delegater = PreQueryPrepare(query_meta)
    pre_delegater.prepare()

    if not info_dic.get("timeout") :
        timeout = 1
    elif "," in info_dic.get("timeout"):
        timeout=int(info_dic.get("timeout").split(",")[0])
        sep_time=float(info_dic.get("timeout").split(",")[1])
    else:
        timeout=int(info_dic.get("timeout"))
        sep_time=1

    for i in range(timeout):
        try:
            res, err, time_cost = obj.do_execute_query(query_meta)
            post_delegater = PostQueryCheck(res, err, time_cost, query_meta)
            post_delegater.check_result()
            break
        except Exception as e:
            logger.info(f"result is not out yet,retry {i} times")
            if i == timeout-1:
                raise e
            else:
                time.sleep(sep_time)
    return res, err
 