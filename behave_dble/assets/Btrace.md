
## Btrace
### 1.背景&介绍：btrace是一个可靠的，用来动态跟踪Java程序的工具。它通过动态对运行中的Java程序进行字节码生成来工作。这里利用了BTrace会对运行中的Java程序的类插入一些跟踪操作来对被跟踪的程序进行热替换的功能，以满足某些特殊场景的测试。
* [github地址](https://github.com/btraceio/btrace)  
* [下载地址](https://github.com/btraceio/btrace/releases)  
* [使用教程](https://json-liu.gitbooks.io/btrace/content/)  

注意：使用BTrace v.1.3.11.1

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

### 3.dble中可进行btrace断点（共87个）：

* ucore集群调试延时点

|clazz#method|line|probe-point desc|
|----|----|----|----|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterGetLock||dble1 视图操作时获取到分布式锁之后|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterViewSetKey||dble1 将具体的视图信息发送到ucore上之后|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterViewNotic||dble1 view视图操作通知到集群之后|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayWhenReponseViewNotic||dble2 收到集群通知之后|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayBeforeReponseGetView||dble2 收到集群通知并发现这个通知需要dble2去更新本地视图信息之后|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayBeforeReponseView||dble2 收到集群通知之后动作完成，准备回写key进行响应的时候|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#beforeDeleteViewNotic||dble1 已收到所有其他dble节点的响应并准备删除此次通知之前|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#beforeReleaseViewLock||dble1 准备释放锁之前|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterDdlLockMeta||dble1 ddl操作获取到ucore锁之后|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterDdlExecuted||dble1 ddl执行完毕之后|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayBeforeDdlNotice||dble1 ddl执行完毕之后，发次ddl集群通知之前|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterDdlNotice||dble2 收到集群通知准备响应ddl事件|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayBeforeDdlNoticeDeleted||dble1 收到其他所有dble节点的事件响应并删除此次通知之前|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayBeforeDdlLockRelease||dble1 ddl准备释放锁之前|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterGetDdlNotice||dble2 获取ddl sql之后|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayBeforeUpdateMeta||dble2 收到集群通知执行变更meta之前|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayBeforeDdlResponse||dble2 ddl结果通知集群之前|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterReloadLock||dble1 reload时，获取分布式锁|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterGetNotice||dble2 获取集群通知之后|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterMasterLoad||dble1 reload完成之后，通知集群之前|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayBeforeSlaveReload||dble2 开始reload，实际reload操作之前|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterSlaveReload||dble2 实际reload操作之后，通知reload结果到集群之前|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayBeforeDeleteReloadLock||等所有dble reload操作完后，删除reload的分布式锁之前|
|com.actiontech.dble.cluster.general.impl.UcoreSender#alert||发送告警到ucore前延迟|
|com.actiontech.dble.alarm.NoAlert#alert||发送告警|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delaycommit||事务下发commit之后延迟##待定|
|resetCommitNodesHandler||丢弃|



* 简单sql语句执行流程可断点

|clazz#method|line|probe-point desc|
|----|----|----|----|
|com.actiontech.dble.btrace.provider.CostTimeProvider#beginRequest||前段开始请求|
|com.actiontech.dble.server.NonBlockingSession#setRequestTime||收到前端请求|
|com.actiontech.dble.server.NonBlockingSession#startProcess||开始处理请求~开始解析|
|com.actiontech.dble.server.NonBlockingSession#endParse||解析结束，准备计算路由|
|com.actiontech.dble.server.NonBlockingSession#endRoute||路由计算结束，准备下发sql|
|com.actiontech.dble.server.NonBlockingSession#readyToDeliver||准备交付（在setPreExecuteEnd断点之前）|
|com.actiontech.dble.server.NonBlockingSession#setPreExecuteEnd||下发前准备工作结束（对于ddl：指“select 1”返回结果；对于查询：指下一步要下发sql）|
|com.actiontech.dble.btrace.provider.CostTimeProvider#startExecuteBackend||将sql下发节点实例|
|com.actiontech.dble.btrace.provider.CostTimeProvider#execLastBack||将sql下发至最后节点实例|
|com.actiontech.dble.server.NonBlockingSession#setBackendResponseTime||收到后端mysql返回的结果（指已收到一个包的返回）|
|com.actiontech.dble.btrace.provider.CostTimeProvider#resFromBack||收到第一个节点实例返回的时间点（在setBackendResponseTime断点中）|
|com.actiontech.dble.btrace.provider.CostTimeProvider#resLastBack||收到最后节点实例返回的时间点（在setBackendResponseTime断点中，且在resFromBack断点之后）|
|com.actiontech.dble.btrace.provider.CostTimeProvider#allBackendConnReceive||所有的连接(节点实例)结果集都返回了的时间点|
|com.actiontech.dble.server.NonBlockingSession#setResponseTime||收到mysql返回的结果，准备返回结果给客户端（一般select）|
|com.actiontech.dble.btrace.provider.CostTimeProvider#beginResponse||实质于等于setResponseTime断点|
|com.actiontech.dble.server.NonBlockingSession#setStageFinished||准备返回结果（ok或error）给客户端（如ddl，insert/update/delete等）|
|com.actiontech.dble.server.NonBlockingSession#setBackendResponseEndTime||后端mysql返回完整结果（每个后端mysql节点返回完整结果都会走到这里）|
|com.actiontech.dble.server.NonBlockingSession#setBeginCommitTime||分布式事务准备提交|
|com.actiontech.dble.server.NonBlockingSession#setHandlerEnd||处理逻辑到了哪个阶段（具体阶段请参考：com.actiontech.dble.serverSessionStage.java|

* 复杂sql语句执行流程可断点

|clazz#method|line|probe-point desc|
|----|----|----|----|
|com.actiontech.dble.btrace.provider.ComplexQueryProvider#endRoute||路由计算结束，准备下发sql|
|com.actiontech.dble.btrace.provider.ComplexQueryProvider#endComplexExecute||下发sql至节点之后|
|com.actiontech.dble.btrace.provider.ComplexQueryProvider#firstComplexEof||mysql返回的eof|

* sql下发多个节点时的断点

|clazz#method|line|probe-point desc|
|----|----|----|----|
|com.actiontech.dble.backend.mysql.nio.handler.MultiNodeQueryHandler#connectionAcquired||获取各个节点的最终连接|
|com.actiontech.dble.backend.mysql.nio.handler.MultiNodeQueryHandler#handleEndPacket||构造分布事务的结束包|


* 刷新连接池可断点

|clazz#method|line|probe-point desc|
|----|----|----|----|
|com.actiontech.dble.btrace.provider.ConnectionPoolProvider#freshConnGetRealodLocekAfter||刷新连接池操作，会获取reload锁(此锁的目的与持有reload锁的操作是互斥的)|
|com.actiontech.dble.btrace.provider.ConnectionPoolProvider#stopConnGetFrenshLocekAfter||刷新连接池，进入停止连接阶段获取锁(此锁与获取连接(与getConnGetFrenshLocekAfter)是互斥的)|
|com.actiontech.dble.btrace.provider.ConnectionPoolProvider#getConnGetFrenshLocekAfter||从连接池中获取连接时获取锁|


* xa事务调试断点

|clazz#method|line|probe-point desc|
|----|----|----|----|
|com.actiontech.dble.btrace.provider.XaDelayProvider#delayBeforeXaStart||下发XA START之前|
|com.actiontech.dble.btrace.provider.XaDelayProvider#delayBeforeXaEnd||下发XA END之前|
|com.actiontech.dble.btrace.provider.XaDelayProvider#DelayBeforeXaPrepare||下发XA PREPARE之前|
|com.actiontech.dble.btrace.provider.XaDelayProvider#delayBeforeXaCommit||下发XA COMMIT之前|
|com.actiontech.dble.btrace.provider.XaDelayProvider#delayBeforeXaRollback||下发XA ROLLBACK之前|
|com.actiontech.dble.btrace.provider.XaDelayProvider#beforeAddXaToQueue||xa事务添加commitQueue或者rollbackQueue之前|
|com.actiontech.dble.btrace.provider.XaDelayProvider#afterAddXaToQueue||xa事务添加commitQueue或者rollbackQueue之后|
|com.actiontech.dble.btrace.provider.XaDelayProvider#beforeInnerRetry||重试xa的COMMIT/ROLLBACK操作之前|

* 其他

|clazz#method|line|probe-point desc|
|----|----|----|----|
|com.actiontech.dble.meta.ProxyMetaManager#addMetaLock|135|添加元数据(table)锁之后|
|com.actiontech.dble.meta.ProxyMetaManager#removeMetaLock||删除metadata锁之前|
|com.actiontech.dble.backend.heartbeat.MySQLHeartbeat#heartbeat||心跳|
|com.actiontech.dble.config.helper.GetAndSyncDbInstanceKeyVariables#call||异步获取mysql实例的Variables|
|com.actiontech.dble.sqlengine.SQLJob#fieldEofResponse||mysql返回最后字段的响应|
|com.actiontech.dble.backend.mysql.nio.handler.query.impl.BaseSelectHandler#rowResponse||执行select sql下，mysql每行返回的响应|
|com.actiontech.dble.backend.mysql.nio.MySQLConnection#closeInner||后端mysql是实例关闭连接|
|com.actiontech.dble.net.AbstractConnection#write||流写出|
|com.actiontech.dble.net.NIOSocketWR#bufferIsQuit||是否quit|
|com.actiontech.dble.backend.mysql.nio.MySQLConnection#syncAndExecute||sql异步执行|
|com.actiontech.dble.backend.mysql.nio.handler.MultiNodeQueryHandler#errorResponse||多个节点处理时，mysql的error返回|
|com.actiontech.dble.backend.datasource.PhysicalDbInstance#getConnection||获取实例的连接|
|com.actiontech.dble.services.manager.response.DryRun#execute||重载|
|com.actiontech.dble.services.manager.response.ShowBinlogStatus#getQueryResult||dble层执行show @@binlog.status命令时，下发SHOW MASTER STATUS至mysql，获取的结果集|
|com.actiontech.dble.meta.table.GetConfigTablesHandler#handleFinished||处理配置中的表|
|com.actiontech.dble.server.NonBlockingSession#resetCommitNodesHandler||【移除】|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterMasterRollback||【移除】|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayBeforeSlaveRollback||【移除】|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayAfterSlaveRollback||【移除】|
|com.actiontech.dble.btrace.provider.ClusterDelayProvider#delayBeforeDeleterollbackLock||【移除】|
|com.actiontech.dble.server.NonBlockingSession#checkBackupStatus||获取备份状态|
|com.actiontech.dble.singleton.PauseShardingNodeManager#tryResume||回复暂停查询的sharadingNode|
|com.actiontech.dble.services.manager.response.ha.DbGroupHaDisable#execute||开始执行dbGroup @@disable name=''...命令|
|com.actiontech.dble.services.manager.response.ha.DbGroupHaEnable#execute||开始执行dbGroup @@enable name=''...命令|
|com.actiontech.dble.services.manager.response.ha.DbGroupHaSwitch#execute||开始执行dbGroup @@switch name='' master=''命令|
|com.actiontech.dble.cluster.ClusterLogic#syncUserXmlToLocal||user.xml文件落盘|
|com.actiontech.dble.cluster.ClusterLogic#syncDbXmlToLocal||db.xml文件落盘|
|com.actiontech.dble.cluster.ClusterLogic#syncShardingXmlToLocal||sharding.xml文件落盘|

### 小版本改动：
* 版本号

    |clazz#method|line|probe-point desc|
    |----|----|----|----|


