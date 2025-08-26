abstract class ChallengesEventRP {}
class LoadChallengeRP extends ChallengesEventRP {
  String classificacao;
  LoadChallengeRP(this.classificacao);
}
class ResetChallengeRP extends ChallengesEventRP {}