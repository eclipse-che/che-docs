@Dependent
@Alternative
public class AnalyticsManager extends AbstractAnalyticsManager {
    @Inject
    @RestClient
    TelemetryService telemetryService;

...

@Override
public void onEvent(AnalyticsEvent event, String ownerId, String ip, String userAgent, String resolution, Map<String, Object> properties) {
    Map<String, Object> payload = new HashMap<String, Object>(properties);
    payload.put("event", event);
    telemetryService.sendEvent(payload);
}
