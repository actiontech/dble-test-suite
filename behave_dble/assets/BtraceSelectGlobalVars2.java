package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;

@BTrace(unsafe = true)
public final class BtraceSelectGlobalVars2 {

    private BtraceSelectGlobalVars2() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.sqlengine.SQLJob",
            method = "fieldEofResponse"
    )
    public static void fieldEofResponse(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into fieldEofResponse");
        BTraceUtils.print(" sleep __________________________ ");
        Thread.sleep(4000L);
    }

}