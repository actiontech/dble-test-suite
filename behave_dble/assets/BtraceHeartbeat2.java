package com.actiontech.dble.btrace.script;
 
import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
 
@BTrace(unsafe = true)
public final class BtraceHeartbeat2 {
 
    private BtraceHeartbeat2() {
 
    }

   @OnMethod(
            clazz = "com.actiontech.dble.backend.heartbeat.MySQLHeartbeat",
            method = "heartbeat"
    )
   public static void heartbeat() throws Exception {
        BTraceUtils.println("_________________________________________" );
        BTraceUtils.println("before heartbeat_________________---1 " );
        Thread.sleep(1L);
    }   
}