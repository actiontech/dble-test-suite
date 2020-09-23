package com.actiontech.dble.btrace.script;

import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.BTraceUtils;

/*
sleep after freshConn get realod lock
*/

@BTrace(unsafe = true)
public final class FreshConnGetRealodLocekAfter {

    private FreshConnGetRealodLocekAfter() {
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ConnectionPoolProvider",
            method = "freshConnGetRealodLocekAfter"
    )
    public static void freshConnGetRealodLocekAfter() throws Exception{
	BTraceUtils.println("start sleep after freshConn get realod lock");
        BTraceUtils.println("---------------");
        Thread.sleep(10L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }
}