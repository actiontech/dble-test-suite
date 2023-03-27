package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceClusterDetachAttach4 {

    private BtraceClusterDetachAttach4() {

    }

    /**
    * DBLE0REQ-1414
    */
    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeDiffOnlineMap"
    )
    public static void delayBeforeDiffOnlineMap(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into delayBeforeDiffOnlineMap ");
        BTraceUtils.println("---------------");
        Thread.sleep(1L);
        BTraceUtils.println(" sleep end ");
        BTraceUtils.println("---------------");
    }

}
