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

The preparatory work before distribution is over (for ddl: means "select 1" returns the result; for query: means the next sql to be issued)
the way of breakpoint is Kind.RETURN
  */

@BTrace(unsafe = true)
public final class SetPreExecuteEnd {

    private SetPreExecuteEnd() {

    }

  @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "setPreExecuteEnd",
            location = @Location(Kind.RETURN)
    )
    public static void setPreExecuteEnd(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into setPreExecuteEnd ");
        Thread.sleep(10L);
    }
}