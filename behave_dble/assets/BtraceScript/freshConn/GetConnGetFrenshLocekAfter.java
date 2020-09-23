package com.actiontech.dble.btrace.script;

import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.BTraceUtils;

/*
sleep after getConn get read lock
*/

@BTrace(unsafe = true)
public final class GetConnGetFrenshLocekAfter {

    private GetConnGetFrenshLocekAfter() {
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ConnectionPoolProvider",
            method = "getConnGetFrenshLocekAfter"
    )
    public static void getConnGetFrenshLocekAfter() throws Exception{
	BTraceUtils.println("start sleep after getConn get read lock");
        BTraceUtils.println("---------------");
        Thread.sleep(30000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }
}