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
The analysis is over, ready to calculate the route
the way of breakpoint is Kind.RETURN
  */

@BTrace(unsafe = true)
public final class EndParse {

    private EndParse() {

    }

   @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "endParse",
            location = @Location(Kind.RETURN)
    )
    public static void endParse(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into endParse ");
        Thread.sleep(10L);
    }
}