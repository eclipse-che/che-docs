package org.my.group;

import java.util.Map;

import org.eclipse.che.api.core.rest.HttpJsonRequestFactory;
import org.eclipse.che.incubator.workspace.telemetry.base.AbstractAnalyticsManager;
import org.eclipse.che.incubator.workspace.telemetry.base.AnalyticsEvent;

public class AnalyticsManager extends AbstractAnalyticsManager {

    public AnalyticsManager(String apiEndpoint, String workspaceId, String machineToken,
            HttpJsonRequestFactory requestFactory) {
        super(apiEndpoint, workspaceId, machineToken, requestFactory);
    }

    @Override
    public boolean isEnabled() {
        // TODO Auto-generated method stub
        return true;
    }

    @Override
    public void destroy() {
        // TODO Auto-generated method stub
    }

    @Override
    public void onEvent(AnalyticsEvent event, String ownerId, String ip, String userAgent, String resolution,
            Map<String, Object> properties) {
        // TODO Auto-generated method stub
    }

    @Override
    public void increaseDuration(AnalyticsEvent event, Map<String, Object> properties) {
        // TODO Auto-generated method stub
    }

    @Override
    public void onActivity() {
        // TODO Auto-generated method stub
    }
}
