import 'package:prometheus_client/prometheus_client.dart';
import 'package:prometheus_client/format.dart' as format;
import 'package:prometheus_client/runtime_metrics.dart' as runtime_metrics;
import 'package:shelf/shelf.dart';

/// Collector for metrics.
class Metrics {
  late Counter requestCounter;
  late Counter errorCounter;
  late Histogram requestLatency;

  Metrics() {
    runtime_metrics.register();
    requestCounter =
        Counter(name: 'requests', help: 'Counts the number of requests to fetch reviews')
          ..register();
    errorCounter = Counter(name: 'errors', help: 'Counter of failed requests')..register();
    requestLatency = Histogram.exponential(
        name: 'request_latency',
        help: 'Latency of request fetching amplify data.',
        start: 1,
        factor: 1.2,
        count: 50)
      ..register();
  }

  Future<String> serialize() async {
    final buffer = StringBuffer();
    final metrics = await CollectorRegistry.defaultRegistry.collectMetricFamilySamples();
    format.write004(buffer, metrics);
    return (buffer.toString());
  }

  Future<Response> requestHandler(Request _) async => Response.ok(await serialize());
}
