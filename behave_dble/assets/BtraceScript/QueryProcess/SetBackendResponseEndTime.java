package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;
import static com.sun.btrace.BTraceUtils.println;
import static com.sun.btrace.BTraceUtils.str;

import com.sun.btrace.annotations.Kind;
import com.sun.btrace.annotations.Location;

/*
Back-end mysql returns complete results (each back-end mysql node returns complete results will go here)
the way of breakpoint is Kind.RETURN
  */

@BTrace(unsafe = true)
public final class SetBackendResponseEndTime {

    private SetBackendResponseEndTime() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "setBackendResponseEndTime",
            location = @Location(Kind.RETURN)
    )
    public static void setBackendResponseEndTime(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into setBackendResponseEndTime ");
        Thread.sleep(10L);
    }
}