package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;

@BTrace(unsafe = true)
public final class borrowConnectionBefore {
    private borrowConnectionBefore() {

    }

	@OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ConnectionPoolProvider",
            method = "borrowConnectionBefore"
    )
    public static void borrowConnectionBefore(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into borrowConnectionBefore");
        BTraceUtils.println("---------------");
        Thread.sleep(10L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }

    
}