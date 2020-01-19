package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;


@BTrace(unsafe = true)
public final class BtraceClusterDelay {

    private BtraceClusterDelay() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.meta.ProxyMetaManager",
            method = "removeMetaLock"
    )
    public static void removeMetaLock(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("delay in removeMetaLock");
        BTraceUtils.print(" for order __________________________ ");
        Thread.sleep(10000L);
    }

}