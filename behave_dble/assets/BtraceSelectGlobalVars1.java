package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;

@BTrace(unsafe = true)
public final class BtraceSelectGlobalVars1 {

    private BtraceSelectGlobalVars1() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.config.helper.GetAndSyncDbInstanceKeyVariables",
            method = "call"
    )
    public static void call(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into call");
        BTraceUtils.print(" sleep __________________________ ");
        Thread.sleep(3000L);
    }

}