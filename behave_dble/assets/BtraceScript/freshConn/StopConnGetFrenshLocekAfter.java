package com.actiontech.dble.btrace.script;

import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.BTraceUtils;

/*
sleep after freshConn freshConn add writeLock
*/

@BTrace(unsafe = true)
public final class StopConnGetFrenshLocekAfter {

    private StopConnGetFrenshLocekAfter() {
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ConnectionPoolProvider",
            method = "stopConnGetFrenshLocekAfter"
    )
    public static void stopConnGetFrenshLocekAfter() throws Exception{
	BTraceUtils.println("start sleep after freshConn add writeLock");
        BTraceUtils.println("---------------");
        Thread.sleep(10L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }

}