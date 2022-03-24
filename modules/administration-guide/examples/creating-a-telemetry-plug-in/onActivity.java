public class AnalyticsManager extends AbstractAnalyticsManager {

    ...

    private long inactiveTimeLimit = 60000 * 3;

    ...

    @Override
    public void onActivity() {
        if (System.currentTimeMillis() - lastEventTime >= inactiveTimeLimit) {
            onEvent(WORKSPACE_INACTIVE, lastOwnerId, lastIp, lastUserAgent, lastResolution, commonProperties);
        }
    }
