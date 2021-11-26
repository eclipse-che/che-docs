@Override
public void onEvent(AnalyticsEvent event, String ownerId, String ip, String userAgent, String resolution, Map<String, Object> properties) {
    HttpClient httpClient = HttpClients.createDefault();
    HttpPost httpPost = new HttpPost("http://little-telemetry-backend-che.apps-crc.testing/event");
    HashMap<String, Object> eventPayload = new HashMap<String, Object>(properties);
    eventPayload.put("event", event);
    StringEntity requestEntity = new StringEntity(new JsonObject(eventPayload).toString(),
            ContentType.APPLICATION_JSON);
    httpPost.setEntity(requestEntity);
    try {
        HttpResponse response = httpClient.execute(httpPost);
    } catch (IOException e) {
        e.printStackTrace();
    }
}
