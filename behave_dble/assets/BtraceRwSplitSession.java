package btrace;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;
import com.sun.btrace.annotations.Kind;
import com.sun.btrace.annotations.Location;

@BTrace(unsafe = true)
public class BtraceRwSplitSession{

    @OnMethod(
            clazz = "com.actiontech.dble.backend.datasource.PhysicalDbGroup",
            method = "bindRwSplitSession",
            location = @Location(Kind.RETURN)
    )
    public static void bindRwSplitSession(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println(BTraceUtils.timestamp("yyyy-MM-dd HH:mm:ss.SSS") + "-----get into bindRwSplitSession");
        Thread.sleep(2000L);
        BTraceUtils.println(BTraceUtils.timestamp("yyyy-MM-dd HH:mm:ss.SSS") + "-----sleep end ");
        BTraceUtils.println();
    }
}