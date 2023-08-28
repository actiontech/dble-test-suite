package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutslowlog {
    private BtraceAboutslowlog() {
    }
    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.SlowLogProvider",
            method = "setShardingNodes"
    )
    public static void setShardingNodes(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("enter setShardingNodes");
    }

}