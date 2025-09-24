/**
 * @description Adapter class for Nebula logging framework integration
 */
public inherited sharing class NebulaAdapter {
    private static Callable nebula; // cached

    // Resolve Nebula's callable class (managed or unlocked)
    private static Callable get() {
        if (nebula != null) {
            return nebula;
        }
        Type t = Type.forName('Nebula', 'CallableLogger'); // managed (namespace Nebula)
        if (t == null) {
            t = Type.forName('CallableLogger'); // unlocked (no namespace)
        }
        nebula = (t == null) ? null : (Callable)t.newInstance();
        return nebula;
    }

    public static Boolean isAvailable() { 
        return get() != null; 
    }

    // Simplified helpers
    public static void info(String message, SObject record) {
        log(LoggingLevel.INFO, message, record);
    }
    public static void debug(String message, SObject record) {
        log(LoggingLevel.DEBUG, message, record);
    }
    public static void error(String message, SObject record, Exception ex) {
        if (NebulaAdapter.isAvailable()) {
            Map<String, Object> args = new Map<String, Object>{
                'loggingLevel' => LoggingLevel.ERROR,
                'message'      => message,
                'exception'    => ex,
                'record'       => record
            };
            call('newEntry', args);
            call('saveLog', null);
        } else {
            // Fallback to System.debug
            String debugMsg = 'RestLib ERROR: ' + message;
            if (record != null) {
                debugMsg += ' | Record: ' + record.Id;
            }
            if (ex != null) {
                debugMsg += ' | Exception: ' + ex.getMessage();
            }
            System.debug(LoggingLevel.ERROR, debugMsg);
        }
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static void logHttpRequest(String title, HttpRequest req, List<String> headersToLog, SObject record) {
        String summary = buildRequestSummary(req, headersToLog);
        log(LoggingLevel.DEBUG, title + '\n' + summary, record);
    }
    public static void logHttpResponse(String title, HttpResponse res, SObject record) {
        String summary = buildResponseSummary(res);
        log(LoggingLevel.DEBUG, title + '\n' + summary, record);
    }

    public static void save() {
        if (NebulaAdapter.isAvailable()) {
            call('saveLog', null);
        }
        // System.debug doesn't need explicit saving - it's immediate
    }

    private static void log(LoggingLevel lvl, String msg, SObject record) {
        if (NebulaAdapter.isAvailable()) {
            // Use Nebula
            Map<String, Object> args = new Map<String, Object>{
                'loggingLevel' => lvl,
                'message'      => msg,
                'record'       => record
            };
            call('newEntry', args);
            // Let callers decide when to save; or save each time by uncommenting:
            // call('saveLog', null);
        } else {
            // Fallback to System.debug
            String debugMsg = 'RestLib: ' + msg;
            if (record != null) {
                debugMsg += ' | Record: ' + record.Id;
            }
            System.debug(lvl, debugMsg);
        }
    }

    private static void call(String action, Map<String, Object> args) {
        Callable c = get();
        if (c == null) {
            return; // Nebula not installed => no-op
        }
        try { 
            c.call(action, args); 
        } catch (Exception e) {
            // Silently swallow to keep logging non-fatal for consumers
            System.debug('NebulaAdapter: Failed to call ' + action + ' - ' + e.getMessage());
        }
    }

    private static String buildRequestSummary(HttpRequest r, List<String> headersToLog) {
        List<String> parts = new List<String>();
        parts.add('Method: ' + r.getMethod());
        parts.add('Endpoint: ' + r.getEndpoint());
        if (!String.isBlank(r.getBody())) {
            parts.add('Body: ' + r.getBody());
        }
        if (headersToLog != null && !headersToLog.isEmpty()) {
            List<String> hs = new List<String>();
            for (String h : headersToLog) {
                hs.add(h + '=' + r.getHeader(h));
            }
            parts.add('Headers: ' + String.join(hs, ', '));
        }
        return String.join(parts, '\n');
    }

    private static String buildResponseSummary(HttpResponse r) {
        List<String> parts = new List<String>();
        parts.add('Status: ' + r.getStatus() + ' (' + r.getStatusCode() + ')');
        if (!String.isBlank(r.getBody())) {
            parts.add('Body: ' + r.getBody());
        }
        return String.join(parts, '\n');
    }
}
