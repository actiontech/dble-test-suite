package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
/*
The heartbeat statement was issued successfully but did not return
 */
@BTrace(unsafe = true)
public final class Heartbeat {

    private Heartbeat() {

    }
   @OnMethod(
            clazz = "com.actiontech.dble.backend.heartbeat.MySQLHeartbeat",
            method = "heartbeat"
    )
   public static void heartbeat() throws Exception {
        BTraceUtils.println("before heartbeat_________________---1 " );
        BTraceUtils.println("before heartbeat_____________--2 " );
        Thread.sleep(30000L);
        BTraceUtils.println("before heartbeat_____________--3 " );
    }
}