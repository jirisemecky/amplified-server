import 'dart:convert';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:pinecone/pinecone.dart';

import 'embeddings.dart';
import 'env.dart';

// Configure routes.
final _router = Router()
  ..get('/', _handleRequests)
  ..get('/status/<message>', _statusHandler)
  ..get('/status', _statusHandler);

Response _statusHandler(Request request) {
  final message = request.params['message'];
  return message == null ? Response.ok('OK') : Response.ok('OK: $message');
}

Future<Response> _handleRequests(Request request) async {
  var query = request.url.queryParameters['q'];

  print('Responding to query "$query"...');

  var queryVector = await EmbeddingsFetcher().get(query);

  QueryResponse? queryResponse = await ServerConfig.pinecone.queryVectors(
      indexName: ServerConfig.pineconeIndex,
      projectId: ServerConfig.pineconeProject,
      environment: ServerConfig.environment,
      request: QueryRequest(
          vector: queryVector, includeMetadata: true, namespace: ServerConfig.pineconeNamespace, topK: 8));

  var jsonString = jsonEncode(queryResponse);

  return Response.ok(jsonString, headers: {"Access-Control-Allow-Origin": "*"});
}

final class ServerConfig {
  static const String apiKey = 'e15b46a4-0176-4294-b795-f31cae1ec327';
  static const String environment = 'us-west4-gcp-free';
  static const String pineconeIndex = 'openai';
  static const String pineconeProject = '9606be2';
  static const String pineconeNamespace = 'withsource2';

  static final pinecone = PineconeClient(apiKey: apiKey);
}

void main(List<String> args) async {
  OpenAI.apiKey = Env.openAIKey;

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '4040');
  final server = await serve(handler, ip, port);
  print('Amplified server started on port ${server.port}');
}
