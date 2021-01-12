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


@BTrace(unsafe = true)
public final class BtraceSessionStage {

    private BtraceSessionStage() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "setRequestTime",
            location = @Location(Kind.RETURN)
    )
    public static void setRequestTime(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into setRequestTime " );
        BTraceUtils.println("------- get into setRequestTime -------");
        BTraceUtils.println();
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into setRequestTime " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "startProcess",
            location = @Location(Kind.RETURN)
    )
    public static void startProcess(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into startProcess " );
        BTraceUtils.println("------- get into startProcess -------");
        BTraceUtils.println();
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into startProcess " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "endParse",
            location = @Location(Kind.RETURN)
    )
    public static void endParse(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into endParse " );
        BTraceUtils.println("------- get into endParse -------");
        BTraceUtils.println();
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into endParse " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "endRoute",
            location = @Location(Kind.RETURN)
    )
    public static void endRoute(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into endRoute " );
        BTraceUtils.println("------- get into endRoute -------");
        BTraceUtils.println();
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into endRoute " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "setPreExecuteEnd",
            location = @Location(Kind.RETURN)
    )
    public static void setPreExecuteEnd(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into setPreExecuteEnd " );
        BTraceUtils.println("------- get into setPreExecuteEnd -------");
        BTraceUtils.println();
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into setPreExecuteEnd " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "setBackendResponseTime",
            location = @Location(Kind.RETURN)
    )
    public static void setBackendResponseTime(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into setBackendResponseTime " );
        BTraceUtils.println("------- get into setBackendResponseTime -------");
        BTraceUtils.println();
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into setBackendResponseTime " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "setResponseTime",
            location = @Location(Kind.RETURN)
    )
    public static void setResponseTime(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into setResponseTime " );
        BTraceUtils.println("------- get into setResponseTime -------");
        BTraceUtils.println();
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into setResponseTime " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "setStageFinished",
            location = @Location(Kind.RETURN)
    )
    public static void setStageFinished(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into setStageFinished " );
        BTraceUtils.println("------- start get into setStageFinished -------");
        BTraceUtils.println();
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into setStageFinished " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "setBackendResponseEndTime",
            location = @Location(Kind.RETURN)
    )
    public static void setBackendResponseEndTime(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into setBackendResponseEndTime " );
        BTraceUtils.println("------- get into setBackendResponseEndTime -------");
        BTraceUtils.println();
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into setBackendResponseEndTime " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "setBeginCommitTime",
            location = @Location(Kind.RETURN)
    )
    public static void setBeginCommitTime(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into setBeginCommitTime " );
        BTraceUtils.println("------- get into setBeginCommitTime -------");
        BTraceUtils.println();
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into setBeginCommitTime " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "setHandlerEnd",
            location = @Location(Kind.RETURN)
    )
    public static void setHandlerEnd(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into setHandlerEnd " );
        BTraceUtils.println("------- get into setHandlerEnd -------");
        BTraceUtils.println();
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into setHandlerEnd " );
        BTraceUtils.println();
    }

}