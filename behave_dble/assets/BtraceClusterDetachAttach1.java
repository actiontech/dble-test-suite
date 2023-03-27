package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceClusterDetachAttach1 {

    private BtraceClusterDetachAttach1() {

    }

    /**
    * hang detach/attach command for other sql is being executed
    */
    @OnMethod(
            clazz = "com.actiontech.dble.services.manager.handler.ClusterManageHandler",
            method = "handle"
    )
    public static void handle(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println(" get into cluster detach or attach handle ");
        BTraceUtils.println("---------------");
        Thread.sleep(1L);
        BTraceUtils.println(" sleep end ");
        BTraceUtils.println("---------------");
    }
}
