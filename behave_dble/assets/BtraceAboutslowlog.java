package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutslowlog {
    private BtraceAboutslowlog() {
    }
    @OnMethod(
            clazz = "com.actiontech.dble.statistic.trace.TraceResult",
            method = "setShardingNodes"
    )
    public static void testSetShardingNode() {
        BTraceUtils.println("enter setShardingNodes");
    }

}