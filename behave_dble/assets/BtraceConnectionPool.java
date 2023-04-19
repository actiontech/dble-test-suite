package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;

@BTrace(unsafe = true)
public final class BtraceConnectionPool {

    private BtraceConnectionPool() {

    }

	@OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ConnectionPoolProvider",
            method = "/.*/"
    )
    public static void printAllMethod(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("------" + BTraceUtils.currentThread().getName() + "------" + probeMethod);
    }

}