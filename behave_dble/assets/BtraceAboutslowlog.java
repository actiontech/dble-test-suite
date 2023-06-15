package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutslowlog {
    private BtraceAboutslowlog() {
    }
//     @OnMethod(
//             clazz = "com.actiontech.dble.server.trace.TraceResult",
//             method = "setShardingNodes",
//             location = @Location(value = Kind.LINE, line = 93)
//     )
//     public static void testSetShardingNode() {
//         BTraceUtils.println("enter setShardingNodes");
//     }

	@OnMethod(
		clazz = "com.actiontech.dble.server.status.SlowQueryLog",
		method = "putSlowQueryLog"
	)
	public static void beforeAuthSuccess(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
		BTraceUtils.println("get into putSlowQueryLog");
		BTraceUtils.println("---------------");
		BTraceUtils.Threads.jstack();
		BTraceUtils.println(BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss"));
		Thread.sleep(1L);
		BTraceUtils.println("sleep end ");
		BTraceUtils.println("---------------");
	}



}