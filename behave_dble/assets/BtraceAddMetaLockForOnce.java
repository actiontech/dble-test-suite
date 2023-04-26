package demo.test;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;

import java.util.concurrent.atomic.AtomicInteger;

@BTrace(unsafe = true)
public class BtraceAddMetaLockForOnce {
    private static final AtomicInteger num = new AtomicInteger(0);

    @OnMethod(
            clazz = "com.actiontech.dble.meta.ProxyMetaManager",
            method = "addMetaLock",
            location = @Location(Kind.RETURN)
    )
    public static void sleepWhenAddMetaLock(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        if (num.get() == 0) {
            num.incrementAndGet();
            BTraceUtils.print("get into addMetaLock,start sleep ");
            BTraceUtils.print(" __________________________ ");
            Thread.sleep(15000L);
            BTraceUtils.print("sleep end ");
            BTraceUtils.print(" __________________________ ");
        }
    }
}