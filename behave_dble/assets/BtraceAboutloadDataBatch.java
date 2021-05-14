package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;

@BTrace(unsafe = true)
public final class BtraceAboutloadDataBatch {
    private BtraceAboutloadDataBatch() {

    }

	@OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
            method = "delayBeforeLoadData"
    )
    public static void delayBeforeLoadData(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into delayBeforeLoadData");
        BTraceUtils.println("---------------");
        Thread.sleep(10000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }

}
