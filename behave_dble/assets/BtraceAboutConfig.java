package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutConfig {
	private BtraceAboutConfig() {
	}

	@OnMethod(
            clazz = "com.actiontech.dble.config.helper.KeyVariables",
            method = "setVersion"
	)
	public static void setVersion(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
		BTraceUtils.println("get into setVersion");
		BTraceUtils.println("---------------");
		BTraceUtils.Threads.jstack();
		BTraceUtils.println(BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss"));
		Thread.sleep(15000L);
		BTraceUtils.println("sleep end ");
		BTraceUtils.println("---------------");
	}

}