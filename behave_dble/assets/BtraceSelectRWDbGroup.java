package btrace;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;
import com.sun.btrace.annotations.Kind;
import com.sun.btrace.annotations.Location;
@BTrace(unsafe = true)
public class BtraceSelectRWDbGroup{

    @OnMethod(
            clazz = "com.actiontech.dble.rwsplit.RWSplitNonBlockingSession",
            method = "reSelectRWDbGroup"

    )
    public static void reSelectRWDbGroup(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into reSelectRWDbGroup");
        Thread.sleep(5000L);
        BTraceUtils.println("sleep end ");
    }
}