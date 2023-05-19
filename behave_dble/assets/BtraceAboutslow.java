package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutslow {
	private BtraceAboutslow() {
	}

	@OnMethod(
		clazz = "com.actiontech.dble.log.slow.SlowQueryLogProcessor",
		method = "putSlowQueryLog"
	)
	public static void putSlowQueryLog(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
		BTraceUtils.println("get into putSlowQueryLog");
		BTraceUtils.println("---------------");
		BTraceUtils.Threads.jstack();
		BTraceUtils.println(BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss"));
		Thread.sleep(120000L);
		BTraceUtils.println("sleep putSlowQueryLog ");
		BTraceUtils.println("---------------");
	}

}

