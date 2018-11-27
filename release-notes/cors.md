

## Adding properties to toggle on/off CORS authentication

Tomcat 8.5.32 introduced changes to CORS filter that will disallow it's usage with following configuration:
```
cors.support.credentials=true
cors.allowed.origins=*
```

More info at https://bz.apache.org/bugzilla/show_bug.cgi?id=62343 

Currently we use CORS filters with such configuration on Che for WS Master and WS Agent Tomcats. 
Attempting to use a CORS filter with such configuration will result in exception.

## Adding properties to change CORS authentication 

in Che 6.15, a possibility will be added to override certain parameters of CORS filter https://github.com/eclipse/che/issues/12058
so tha values for `cors.credential.support` and `cors.allowed.origin` via corresponding env.variables (che properties)

while this ability will be added, CORS settings and Tomcat version will remain the same.

## Upgrading Tomcat & CORS configuration

In future versions of Che, whenever Tomcat will be upgraded, the CORS configuration should change as well

for WS Master we want to test the following configuration:

```
cors.support.credentials=false
cors.allowed.origins=*
```

For WS Agent, we make use of requests with credentials, so CORS has to support that.
So we will have to define an allowed origin of WS Master's Domain, which we can do at runtime, by infering it from CHE_API property


```
cors.support.credentials=true
cors.allowed.origins will be configured in runtime, infered from CHE_API (WS Master domain)
```

