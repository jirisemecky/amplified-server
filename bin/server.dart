import 'dart:convert';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:prometheus_client/prometheus_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:pinecone/pinecone.dart';

import 'package:prometheus_client/format.dart' as format;
import 'package:prometheus_client/runtime_metrics.dart' as runtime_metrics;

import 'embeddings.dart';
import 'env.dart';

/// Collector for metrics.
class Metrics {
  late Counter requestCounter;

  Metrics() {
    runtime_metrics.register();
    requestCounter = Counter(name: 'number_of_requests',
        help: 'Counts the number of requests to fetch reviews');
  }

  Future<String> serialize() async {
    final buffer = StringBuffer();
    // TODO: this is not returning the metric that I'm writing to, only some default ones.
    final metrics = await CollectorRegistry.defaultRegistry.collectMetricFamilySamples();
    format.write004(buffer, metrics);
    return(buffer.toString());
  }
}

/// The server
class AmplifiedServer {
  static const String apiKey = 'e15b46a4-0176-4294-b795-f31cae1ec327';
  static const String environment = 'us-west4-gcp-free';
  static const String pineconeIndex = 'openai';
  static const String pineconeProject = '9606be2';
  static const String pineconeNamespace = 'withsource2';
  static final pinecone = PineconeClient(apiKey: Env.pineconeKey);

  Metrics metrics = Metrics();
  InternetAddress ip;
  int port;
  late final Handler _handler;

  AmplifiedServer(this.ip, this.port) {
    // Configure routes.
   var _router = Router()
      ..get('/', _requestHandler)
      ..get('/metrics', _metricsHandler)
      ..get('/status', _statusHandler);

    // Configure a pipeline that logs requests.
    _handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);
  }

  void start() async {
    final server = await serve(_handler, ip, port);
    print('Amplified server started on IP ${ip} and port ${server.port}');
  }

  Response _statusHandler(Request request) => Response.ok('OK');

  Future<Response> _metricsHandler(Request _) async => Response.ok(await metrics.serialize());

  Future<Response> _requestHandler(Request request) async {
    var query = request.url.queryParameters['q'];

    print('Responding to query "$query"...');

    var queryVector = await EmbeddingsFetcher().get(query);

    QueryResponse? queryResponse = await pinecone.queryVectors(
        indexName: pineconeIndex,
        projectId: pineconeProject,
        environment: environment,
        request: QueryRequest(
            vector: queryVector, includeMetadata: true, namespace: pineconeNamespace, topK: 8));

    var jsonString = jsonEncode(queryResponse);

    return Response.ok(jsonString, headers: {"Access-Control-Allow-Origin": "*"});
  }
}

void main(List<String> args) async {
  OpenAI.apiKey = Env.openAIKey;

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '4040');

  final server = AmplifiedServer(ip, port);
  server.start();
}
