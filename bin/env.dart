import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(requireEnvFile: true)
abstract class Env {
  @EnviedField(varName: 'OPENAI_KEY')
  static const String openAIKey = _Env.openAIKey;

  @EnviedField(varName: 'PINECONE_KEY')
  static const String pineconeKey = _Env.pineconeKey;

  @EnviedField(varName: 'OPENAI_MODEL', defaultValue: 'text-embedding-ada-002')
  static const String openAIModel = _Env.openAIModel;

  @EnviedField(varName: 'PINECONE_NAMESPACE', defaultValue: 'v2')
  static const String pineconeNamespace = _Env.pineconeNamespace;

  @EnviedField(varName: 'PINECONE_INDEX', defaultValue: 'openai')
  static const String pineconeIndex = _Env.pineconeIndex;

  @EnviedField(varName: 'PINECONE_PROJECT', defaultValue: '9606be2')
  static const String pineconeProject = _Env.pineconeProject;

  @EnviedField(varName: 'PINECONE_ENVIRONMENT', defaultValue: 'us-west4-gcp-free')
  static const String pineconeEnvironment = _Env.pineconeEnvironment;

  @EnviedField(varName: 'NUMBER_OF_RESULTS', defaultValue: 12)
  static const int numberOfResults = _Env.numberOfResults;
}
