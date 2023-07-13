import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
  @EnviedField(varName: 'OPEN_AI_KEY')
  static const String openAIKey = _Env.openAIKey;
}
