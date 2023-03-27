package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceClusterDetachAttach6 {

    private BtraceClusterDetachAttach6() {

    }

   /**
    * one dble is executing detach command, another dble will execute cluster sql (zk)
    */
    @OnMethod(
            clazz = "com.actiontech.dble.cluster.zkprocess.ZkSender",
            method = "detachCluster"
    )
    public static void zkDetachCluster(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into zkDetachCluster ");
        BTraceUtils.println("---------------");
        Thread.sleep(1L);
        BTraceUtils.println(" sleep end ");
        BTraceUtils.println("---------------");
    }

   /**
    * one dble is executing detach command, another dble will execute cluster sql (ucore)
    */
    @OnMethod(
            clazz = "com.actiontech.dble.cluster.general.impl.UcoreSender",
            method = "detachCluster"
    )
    public static void ucoreDetachCluster(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into ucoreDetachCluster ");
        BTraceUtils.println("---------------");
        Thread.sleep(15000L);
        BTraceUtils.println(" sleep end ");
        BTraceUtils.println("---------------");
    }

}
