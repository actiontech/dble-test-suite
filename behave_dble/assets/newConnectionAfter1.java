package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;

@BTrace(unsafe = true)
public final class newConnectionAfter1 {
    private newConnectionAfter1() {

    }
 //仅仅是3.20.10 开发单独给的jar中的一个桩，复现用的
	@OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ConnectionPoolProvider",
            method = "getWaiterCountAfter"
    )
    public static void getWaiterCountAfter(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into getWaiterCountAfter");
        BTraceUtils.println("---------------");
        Thread.sleep(10L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }
}
