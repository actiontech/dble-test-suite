package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;


@BTrace(unsafe = true)
public final class BtraceClusterDelay {

    private BtraceClusterDelay() {

    }


    @OnMethod(
            clazz = "com.actiontech.dble.manager.response.DataHostDisable",
            method = "execute"
    )
    public static void dataHostDisable(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into DataHostDisable ");
        Thread.sleep(10L);

    }

    @OnMethod(
            clazz = "com.actiontech.dble.manager.response.DryRun",
            method = "execute"
    )
    public static void dryrun(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into dryrun ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);

    }

    @OnMethod(
            clazz = "com.actiontech.dble.manager.response.ShowBinlogStatus",
            method = "getQueryResult"
    )
    public static void showBinlogStatus(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into showBinlogStatus ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);

    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "resetCommitNodesHandler"
    )
    public static void delayCommit(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayCommit ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);

    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterGetLock"
    )
    public static void delayAfterGetLock(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterGetLock ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);

    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterViewSetKey"
    )
    public static void delayAfterViewSetKey(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterViewSetKey ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterViewNotic"
    )
    public static void delayAfterViewNotic(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterViewNotic ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayWhenReponseViewNotic"
    )
    public static void delayWhenReponseViewNotic(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayWhenReponseViewNotic ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeReponseGetView"
    )
    public static void delayBeforeReponseGetView(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeReponseGetView ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeReponseView"
    )
    public static void delayBeforeReponseView(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeReponseView ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "beforeDeleteViewNotic"
    )
    public static void beforeDeleteViewNotic(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into beforeDeleteViewNotic ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "beforeReleaseViewLock"
    )
    public static void beforeReleaseViewLock(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into beforeReleaseViewLock ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterDdlLockMeta"
    )
    public static void delayAfterDdlLockMeta(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterDdlLockMeta ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterDdlExecuted"
    )
    public static void delayAfterDdlExecuted(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterDdlExecuted ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeDdlNotice"
    )
    public static void delayBeforeDdlNotice(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeDdlNotice ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }


    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterDdlNotice"
    )
    public static void delayAfterDdlNotice(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterDdlNotice ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeDdlNoticeDeleted"
    )
    public static void delayBeforeDdlNoticeDeleted(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeDdlNoticeDeleted ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }


    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeDdlLockRelease"
    )
    public static void delayBeforeDdlLockRelease(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeDdlLockRelease ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }


    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterReloadLock"
    )
    public static void delayAfterReloadLock(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterReloadLock ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(60000L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterGetNotice"
    )
    public static void delayAfterGetNotice(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterGetNotice ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterMasterLoad"
    )
    public static void delayAfterMasterLoad(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterMasterLoad ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeSlaveReload"
    )
    public static void delayBeforeSlaveReload(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeSlaveReload ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterSlaveReload"
    )
    public static void delayAfterSlaveReload(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterSlaveReload ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeDeleteReloadLock"
    )
    public static void delayBeforeDeleteReloadLock(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeDeleteReloadLock ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterMasterRollback"
    )
    public static void delayAfterMasterRollback(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterMasterRollback ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeSlaveRollback"
    )
    public static void delayBeforeSlaveRollback(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeSlaveRollback ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterSlaveRollback"
    )
    public static void delayAfterSlaveRollback(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterSlaveRollback ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeDeleterollbackLock"
    )
    public static void delayBeforeDeleterollbackLock(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeDeleterollbackLock ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.meta.table.GetConfigTablesHandler",
            method = "handleFinished"
    )
    public static void getSpecialNodeTablesHandlerFinished(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into getSpecialNodeTablesHandlerFinished ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10L);
    }
    @OnMethod(
            clazz = "com.actiontech.dble.backend.mysql.nio.handler.transaction.normal.NormalCommitNodesHandler",
            method = "setResponseTime"
    )
    public static void setResponseTime(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("delay in setResponseTime");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(1000L);
    }


    @OnMethod(
            clazz = "com.actiontech.dble.backend.mysql.nio.handler.query.impl.BaseSelectHandler",
            method = "rowResponse"
    )
    public static void rowResponse(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into rowResponse ");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(200);
    }
    @OnMethod(
            clazz = "com.actiontech.dble.meta.ProxyMetaManager",
            method = "removeMetaLock"
    )
    public static void removeMetaLock(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("delay in removeMetaLock");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(30000L);
    }
   @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayAfterGetDdlNotice"
    )
    public static void delayAfterGetDdlNotice(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayAfterGetDdlNotice");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10000L);
    }
  @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeDdlResponse"
    )
    public static void delayBeforeDdlResponse(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeDdlResponse");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10000L);
    }
 @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeUpdateMeta"
    )
    public static void delayBeforeUpdateMeta(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeUpdateMeta");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10000L);
    }
 @OnMethod(
            clazz = "com.actiontech.dble.cluster.impl.UcoreSender",
            method = "alert"
    )
    public static void delayBeforeAlert(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeAlert");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(30000L);
    }
 @OnMethod(
            clazz = " com.actiontech.dble.alarm.NoAlert",
            method = "alert"
    )
    public static void delayBeforeNoAlert(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into delayBeforeNoAlert");
        BTraceUtils.print(" get into the alert time");
    }
}