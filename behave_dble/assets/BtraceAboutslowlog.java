package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutslowlog {
    private BtraceAboutslowlog() {
    }
    @OnMethod(
            clazz = "com.actiontech.dble.server.trace.TraceResult",
            method = "setShardingNodes",
            location = @Location(value = Kind.LINE, line = 93)
    )
    public static void testSetShardingNode() {
        BTraceUtils.println("enter setShardingNodes");
    }

}