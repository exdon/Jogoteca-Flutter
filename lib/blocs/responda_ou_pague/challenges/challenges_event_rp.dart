abstract class ChallengesEventRP {}
class LoadChallengeRP extends ChallengesEventRP {
  final String classificacao;
  final List<String> completedChallenges;
  final List<String> recentChallenges;

  LoadChallengeRP(this.classificacao, [this.completedChallenges = const [], this.recentChallenges = const []]);
}
class ResetChallengeRP extends ChallengesEventRP {}