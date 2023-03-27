package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceClusterDetachAttach5 {

    private BtraceClusterDetachAttach5() {

    }

   /**
    * one dble is executing detach command, another dble is executing cluster sql (zk)
    */
    @OnMethod(
            clazz = "com.actiontech.dble.cluster.zkprocess.zktoxml.listen.ConfigStatusListener",
            method = "onEvent"
    )
    public static void zkOnEvent(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into zkOnEvent ");
        BTraceUtils.println("---------------");
        Thread.sleep(1L);
        BTraceUtils.println(" sleep end ");
        BTraceUtils.println("---------------");
    }

   /**
    * one dble is executing detach command, another dble is executing cluster sql (ucore)
    */
    @OnMethod(
            clazz = "com.actiontech.dble.cluster.general.response.ConfigStatusResponse",
            method = "onEvent"
    )
    public static void ucoreOnEvent(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into ucoreOnEvent ");
        BTraceUtils.println("---------------");
        Thread.sleep(1L);
        BTraceUtils.println(" sleep end ");
        BTraceUtils.println("---------------");
    }

}
