import 'dart:convert';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:pinecone/pinecone.dart';

import 'config.dart';
import 'embeddings.dart';
import 'env.dart';
import 'metrics.dart';

/// The server
class AmplifiedServer {
  static final embeddings = EmbeddingsFetcher();
  late final PineconeClient pinecone;

  Metrics metrics = Metrics();
  InternetAddress ip;
  int port;
  Env env;
  late final Handler _handler;

  AmplifiedServer(this.ip, this.port, this.env) {
    // Configure routes.
    var _router = Router()
      ..get('/', _requestHandler)
      ..get('/metrics', metrics.requestHandler)
      ..get('/status', _statusHandler);

    // Configure a pipeline that logs requests.
    _handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);
    pinecone = PineconeClient(apiKey: env.pineconeKey);
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

    try {
      var queryVector = await embeddings.get(query);

      QueryResponse? queryResponse = await pinecone.queryVectors(
          indexName: Config.pineconeIndex,
          projectId: Config.pineconeProject,
          environment: Config.pineconeEnvironment,
          request: QueryRequest(
              vector: queryVector,
              includeMetadata: true,
              namespace: Config.pineconeNamespace,
              topK: Config.numberOfResults));

      var jsonString = jsonEncode(queryResponse);

      metrics.requestLatency.observe(stopwatch.elapsedMilliseconds.toDouble());
      stopwatch.stop();
      return Response.ok(jsonString, headers: {"Access-Control-Allow-Origin": "*"});
    } catch (e) {
      metrics.errorCounter.inc();
      return Response.badRequest(body: 'ERROR: $e', headers: {"Access-Control-Allow-Origin": "*"});
    }
  }
}

void main(List<String> args) async {
  Env env = Env();
  OpenAI.apiKey = env.openAIKey;

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '4040');

  final server = AmplifiedServer(ip, port, env);
  server.start();
}
