/// Class holding all non-secret configuration of the server.
final class Config {
  static const String openAIModel = 'text-embedding-ada-002';
  static const String pineconeNamespace = 'v2';
  static const String pineconeIndex = 'openai';
  static const String pineconeProject = '9606be2';
  static const String pineconeEnvironment = 'us-west4-gcp-free';
  static const int numberOfResults = 12;
}
