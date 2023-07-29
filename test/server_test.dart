import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

import '../bin/embeddings.dart';

void main() {
  final port = '8080';
  final host = 'http://0.0.0.0:$port';
  late Process p;

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/amplified_server.dart'],
      environment: {'PORT': port},
    );
    // Wait for server to start and print to stdout.
    await p.stdout.first;
  });

  tearDown(() => p.kill());

  test('Root', () async {
    final response = await get(Uri.parse('$host/?q=${EmbeddingsFetcher.chevyQuery}'));
    expect(response.statusCode, 200);
    expect(response.body, isNotEmpty);
  });

  test('No query', () async {
    final response = await get(Uri.parse('$host'));
    expect(response.statusCode, 400);
    expect(response.body, contains('ERROR'));
  });

  test('Status', () async {
    final response = await get(Uri.parse('$host/status'));
    expect(response.statusCode, 200);
    expect(response.body, 'OK');
  });

  test('404', () async {
    final response = await get(Uri.parse('$host/foobar'));
    expect(response.statusCode, 404);
  });
}
