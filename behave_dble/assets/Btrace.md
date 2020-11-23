
## Btrace
### 1.背景&介绍：btrace是一个可靠的，用来动态跟踪Java程序的工具。它通过动态对运行中的Java程序进行字节码生成来工作。这里利用了BTrace会对运行中的Java程序的类插入一些跟踪操作来对被跟踪的程序进行热替换的功能，以满足某些特殊场景的测试。
* [github地址](https://github.com/btraceio/btrace)  
* [下载地址](https://github.com/btraceio/btrace/releases)  
* [使用教程](https://json-liu.gitbooks.io/btrace/content/)  

### 2.简易使用：
#### 脚本讲解：  
1. 在类加上`@BTrace(unsafe = true)`注解  
2. 在方法中添加`@OnMethod(clazz="",method=""[,location=@Location(value=Kind.LINE/Kind.RETURN[,line=113)]])`注解  
3. btrace的println的打印存在缓冲导致输出信息不全，所以需要使用println()作为打印分割符

#### 例码：
```
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;
import com.sun.btrace.annotations.Location;
import com.sun.btrace.annotations.Duration;
import com.sun.btrace.annotations.Return;
import com.sun.btrace.annotations.Kind;

import com.sun.btrace.BTraceUtils;

@BTrace(unsafe = true)
public final class BtraceAddMetaLock {
    private BtraceAddMetaLock() {

    }
    @OnMethod(
            clazz = "com.actiontech.dble.meta.ProxyMetaManager",
            method = "addMetaLock",
            location=@Location(value=Kind.LINE,line=113)
    )
    public static void sleepWhenAddMetaLockDuring(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time["+startTime+"], start ... " );
        BTraceUtils.println("------- start.... -------");
        BTraceUtils.println(); // 【强调】一定要使用println()，不然以上打印的信息会因为缓冲原因输出不全
        Thread.sleep(3000L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time["+endTime+"], end ... " );
        BTraceUtils.println(); // 【强调】最后一定要使用println()，不然以上打印的信息会因为缓冲原因输出不全
    }
}
```


### 3.执行脚本：
#### 获取程序的进程
```
[root@centos-orcl bin]# jps
28060 WrapperSimpleApp
```

#### 执行脚本
```
btrace -u 28060 ${脚本的路径}
```
注意：一定要带上"-u" 参数，不然对于Thread.sleep等(非BTrace自带)方法是不支持的

### 3.dble中可进行btrace断点（共66个）：

* ucore集群调试延时点

|method|clazz|line|probe-point desc|
|----|----|----|----|----|
|delayAfterGetLock|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 视图操作时获取到分布式锁之后|
|delayAfterViewSetKey|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 将具体的视图信息发送到ucore上之后|
|delayAfterViewNotic|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 view视图操作通知到集群之后|
|delayWhenReponseViewNotic|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble2 收到集群通知之后|
|delayBeforeReponseGetView|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble2 收到集群通知并发现这个通知需要dble2去更新本地视图信息之后|
|delayBeforeReponseView|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble2 收到集群通知之后动作完成，准备回写key进行响应的时候|
|beforeDeleteViewNotic|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 已收到所有其他dble节点的响应并准备删除此次通知之前|
|beforeReleaseViewLock|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 准备释放锁之前|
|delayAfterDdlLockMeta|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 ddl操作获取到ucore锁之后|
|delayAfterDdlExecuted|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 ddl执行完毕之后|
|delayBeforeDdlNotice|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 ddl执行完毕之后，发次ddl集群通知之前|
|delayAfterDdlNotice|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble2 收到集群通知准备响应ddl事件|
|delayBeforeDdlNoticeDeleted|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 收到其他所有dble节点的事件响应并删除此次通知之前|
|delayBeforeDdlLockRelease|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 ddl准备释放锁之前|
|delayAfterGetDdlNotice|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble2 获取ddl sql之后|
|delayBeforeUpdateMeta|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble2 收到集群通知执行变更meta之前|
|delayBeforeDdlResponse|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble2 ddl结果通知集群之前|
|delayAfterReloadLock|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 reload时，获取分布式锁|
|delayAfterGetNotice|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble2 获取集群通知之后|
|delayAfterMasterLoad|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble1 reload完成之后，通知集群之前|
|delayBeforeSlaveReload|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble2 开始reload，实际reload操作之前|
|delayAfterSlaveReload|com.actiontech.dble.btrace.provider.ClusterDelayProvider||dble2 实际reload操作之后，通知reload结果到集群之前|
|delayBeforeDeleteReloadLock|com.actiontech.dble.btrace.provider.ClusterDelayProvider||等所有dble reload操作完后，删除reload的分布式锁之前|
|delayBeforeAlert|com.actiontech.dble.cluster.general.impl.UcoreSender||发送告警到ucore前延迟|
|delaycommit|com.actiontech.dble.btrace.provider.ClusterDelayProvider||事务下发commit之后延迟##待定|
|resetCommitNodesHandler|||丢弃|


* 简单sql语句执行流程可断点

|method|clazz|line|probe-point desc|
|----|----|----|----|----|
|beginRequest|com.actiontech.dble.btrace.provider.CostTimeProvider||前段开始请求|
|setRequestTime|com.actiontech.dble.server.NonBlockingSession||收到前端请求|
|startProcess|com.actiontech.dble.server.NonBlockingSession||开始处理请求~开始解析|
|endParse|com.actiontech.dble.server.NonBlockingSession||解析结束，准备计算路由|
|endRoute|com.actiontech.dble.server.NonBlockingSession||路由计算结束，准备下发sql|
|readyToDeliver|com.actiontech.dble.server.NonBlockingSession||准备交付（在setPreExecuteEnd断点之前）|
|setPreExecuteEnd|com.actiontech.dble.server.NonBlockingSession||下发前准备工作结束（对于ddl：指“select 1”返回结果；对于查询：指下一步要下发sql）|
|startExecuteBackend|com.actiontech.dble.btrace.provider.CostTimeProvider||将sql下发节点实例|
|execLastBack|com.actiontech.dble.btrace.provider.CostTimeProvider||将sql下发至最后节点实例|
|setBackendResponseTime|com.actiontech.dble.server.NonBlockingSession||收到后端mysql返回的结果（指已收到一个包的返回）|
|resFromBack|com.actiontech.dble.btrace.provider.CostTimeProvider||收到第一个节点实例返回的时间点（在setBackendResponseTime断点中）|
|resLastBack|com.actiontech.dble.btrace.provider.CostTimeProvider||收到最后节点实例返回的时间点（在setBackendResponseTime断点中，且在resFromBack断点之后）|
|allBackendConnReceive|com.actiontech.dble.btrace.provider.CostTimeProvider||所有的连接(节点实例)结果集都返回了的时间点|
|setResponseTime|com.actiontech.dble.server.NonBlockingSession||收到mysql返回的结果，准备返回结果给客户端（一般select）|
|beginResponse|com.actiontech.dble.btrace.provider.CostTimeProvider||实质于等于setResponseTime断点|
|setStageFinished|com.actiontech.dble.server.NonBlockingSession||准备返回结果（ok或error）给客户端（如ddl，insert/update/delete等）|
|setBackendResponseEndTime|com.actiontech.dble.server.NonBlockingSession||后端mysql返回完整结果（每个后端mysql节点返回完整结果都会走到这里）|
|setBeginCommitTime|com.actiontech.dble.server.NonBlockingSession||分布式事务准备提交|
|setHandlerEnd|com.actiontech.dble.server.NonBlockingSession||处理逻辑到了哪个阶段（具体阶段请参考：com.actiontech.dble.serverSessionStage.java|

* 复杂sql语句执行流程可断点

|method|clazz|line|probe-point desc|
|----|----|----|----|----|
|endRoute|com.actiontech.dble.btrace.provider.ComplexQueryProvider||路由计算结束，准备下发sql|
|endComplexExecute|com.actiontech.dble.btrace.provider.ComplexQueryProvider||下发sql至节点之后|
|firstComplexEof|com.actiontech.dble.btrace.provider.ComplexQueryProvider||mysql返回的eof|

* sql下发多个节点时的断点

|method|clazz|line|probe-point desc|
|----|----|----|----|----|
|connectionAcquired|com.actiontech.dble.backend.mysql.nio.handler.MultiNodeQueryHandler||获取各个节点的最终连接|
|handleEndPacket|com.actiontech.dble.backend.mysql.nio.handler.MultiNodeQueryHandler||构造分布事务的结束包|


* 刷新连接池可断点

|method|clazz|line|probe-point desc|
|----|----|----|----|----|
|freshConnGetRealodLocekAfter|com.actiontech.dble.btrace.provider.ConnectionPoolProvider||刷新连接池操作，会获取reload锁(此锁的目的与持有reload锁的操作是互斥的)|
|stopConnGetFrenshLocekAfter|com.actiontech.dble.btrace.provider.ConnectionPoolProvider||刷新连接池，进入停止连接阶段获取锁(此锁与获取连接(与getConnGetFrenshLocekAfter)是互斥的)|
|getConnGetFrenshLocekAfter|com.actiontech.dble.btrace.provider.ConnectionPoolProvider||从连接池中获取连接时获取锁|


* xa事务调试断点

|method|clazz|line|probe-point desc|
|----|----|----|----|----|
|delayBeforeXaStart|com.actiontech.dble.btrace.provider.XaDelayProvider||下发XA START之前|
|delayBeforeXaEnd|com.actiontech.dble.btrace.provider.XaDelayProvider||下发XA END之前|
|DelayBeforeXaPrepare|com.actiontech.dble.btrace.provider.XaDelayProvider||下发XA PREPARE之前|
|delayBeforeXaCommit|com.actiontech.dble.btrace.provider.XaDelayProvider||下发XA COMMIT之前|
|delayBeforeXaRollback|com.actiontech.dble.btrace.provider.XaDelayProvider||下发XA ROLLBACK之前|
|beforeAddXaToQueue|com.actiontech.dble.btrace.provider.XaDelayProvider||xa事务添加commitQueue或者rollbackQueue之前|
|afterAddXaToQueue|com.actiontech.dble.btrace.provider.XaDelayProvider||xa事务添加commitQueue或者rollbackQueue之后|
|beforeInnerRetry|com.actiontech.dble.btrace.provider.XaDelayProvider||重试xa的COMMIT/ROLLBACK操作之前|

* 其他

|method|clazz|line|probe-point desc|
|----|----|----|----|----|
|addMetaLock|com.actiontech.dble.meta.ProxyMetaManager|135|添加元数据(table)锁|
|removeMetaLock|com.actiontech.dble.meta.ProxyMetaManager||删除metadata锁之前|
|heartbeat|com.actiontech.dble.backend.heartbeat.MySQLHeartbeat||心跳|
|call|com.actiontech.dble.config.helper.GetAndSyncDbInstanceKeyVariables||异步获取mysql实例的Variables|
|fieldEofResponse|com.actiontech.dble.sqlengine.SQLJob||mysql返回最后字段的响应|
|rowResponse|com.actiontech.dble.backend.mysql.nio.handler.query.impl.BaseSelectHandler||执行select sql下，mysql每行返回的响应|
|getQueryResult|com.actiontech.dble.services.manager.response.ShowBinlogStatus||dble层执行show @@binlog.status命令时，下发SHOW MASTER STATUS至mysql，获取的结果集|

### 小版本改动：
* 版本号

    |method|clazz|line|desc|
    |----|----|----|----|----|


