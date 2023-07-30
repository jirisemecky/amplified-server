import 'package:dotenv/dotenv.dart';

/// Class holding all secret configuration read either from `.env` file of from
/// enviroment variables.
final class Env {
  late String openAIKey;
  late String pineconeKey;

  late DotEnv _dotEnv;

  Env() {
    _dotEnv = DotEnv(includePlatformEnvironment: true)..load();
    openAIKey = _dotEnv['OPENAI_KEY'] ?? '';
    pineconeKey = _dotEnv['PINECONE_KEY'] ?? '';
  }
}
