public class RunOnceTriggerUtil {
    
    @testVisible private static boolean orderProductTriggerRun = true;
   
    public static boolean orderProductTriggerRunOnce() {
        if(orderProductTriggerRun) {
            orderProductTriggerRun = false;
            return true;  
        } else {
            return orderProductTriggerRun;
        }
    }
}