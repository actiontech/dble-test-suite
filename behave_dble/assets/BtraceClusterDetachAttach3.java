package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceClusterDetachAttach3 {

    private BtraceClusterDetachAttach3() {

    }

    /**
    * hang executing sql
    */
    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.GeneralProvider",
            method = "afterDelayServiceMarkDoing"
    )
    public static void afterDelayServiceMarkDoing(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into afterDelayServiceMarkDoing ");
        BTraceUtils.println("---------------");
        Thread.sleep(1L);
        BTraceUtils.println(" sleep end ");
        BTraceUtils.println("---------------");
    }

}
