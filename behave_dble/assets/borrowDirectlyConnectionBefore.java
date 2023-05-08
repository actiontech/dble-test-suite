package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;

@BTrace(unsafe = true)
public final class borrowDirectlyConnectionBefore {
    private borrowDirectlyConnectionBefore() {

    }

	@OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ConnectionPoolProvider",
            method = "borrowDirectlyConnectionBefore"
    )
    public static void borrowDirectlyConnectionBefore(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into borrowDirectlyConnectionBefore");
        BTraceUtils.println("---------------");
        Thread.sleep(10L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }

    
}


