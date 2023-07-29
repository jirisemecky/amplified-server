import 'dart:convert';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:pinecone/pinecone.dart';


import 'embeddings.dart';
import 'env.dart';
import 'metrics.dart';

/// The server
class AmplifiedServer {
  static final embeddings = EmbeddingsFetcher();
  static final pinecone = PineconeClient(apiKey: Env.pineconeKey);

  Metrics metrics = Metrics();
  InternetAddress ip;
  int port;
  late final Handler _handler;

  AmplifiedServer(this.ip, this.port) {
    // Configure routes.
    var _router = Router()
      ..get('/', _requestHandler)..get('/metrics', metrics.requestHandler)..get(
          '/status', _statusHandler);

    // Configure a pipeline that logs requests.
    _handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);
  }

  void start() async {
    final server = await serve(_handler, ip, port);
    print('Amplified server started on IP ${ip} and port ${server.port}');
  }

  Response _statusHandler(Request request) => Response.ok('OK');

  Future<Response> _requestHandler(Request request) async {
    final stopwatch = Stopwatch()..start();
    var query = request.url.queryParameters['q'];
    print('Responding to query "$query"...');
    metrics.requestCounter.inc();

    var queryVector = await embeddings.get(query);

    QueryResponse? queryResponse = await pinecone.queryVectors(
        indexName: Env.pineconeIndex,
        projectId: Env.pineconeProject,
        environment: Env.pineconeEnvironment,
        request: QueryRequest(
            vector: queryVector, includeMetadata: true, namespace: Env.pineconeNamespace, topK: Env.numberOfResults));

    var jsonString = jsonEncode(queryResponse);

    metrics.requestLatency.observe(stopwatch.elapsedMilliseconds.toDouble());
    stopwatch.stop();
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
