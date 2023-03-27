package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceClusterDetachAttach2 {

    private BtraceClusterDetachAttach2() {

    }

    /**
    * hang detach/attach command for other sql will be executed
    */
    @OnMethod(
            clazz = "com.actiontech.dble.services.manager.handler.ClusterManageHandler",
            method = "waitOtherSessionBlocked"
    )
    public static void markDoingOrDelay(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into waitOtherSessionBlocked ");
        BTraceUtils.println("---------------");
        Thread.sleep(1L);
        BTraceUtils.println(" sleep end ");
        BTraceUtils.println("---------------");
    }

}
