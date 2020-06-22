public class AnalyticsManager extends AbstractAnalyticsManager {

    ...

    private long inactiveTimeLimt = 60000 * 3;

    ...

    
    @Override
    public void onActivity() {
        if (System.currentTimeMillis() - lastEventTime >= inactiveTimeLimt) {
            onEvent(WORKSPACE_INACTIVE, lastOwnerId, lastIp, lastUserAgent, lastResolution, commonProperties);       
        }   
    } 
