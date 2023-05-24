package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutslow1 {
	private BtraceAboutslow1() {
	}

	@OnMethod(
		clazz = "com.actiontech.dble.log.slow.SlowQueryLogProcessor",
		method = "writeLog"
	)
	public static void putSlowQueryLog(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
		BTraceUtils.println("get into writeLog");
		BTraceUtils.println("---------------");
		BTraceUtils.Threads.jstack();
		BTraceUtils.println(BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss"));
		Thread.sleep(1200000L);
		BTraceUtils.println("sleep writeLog ");
		BTraceUtils.println("---------------");
	}



}

