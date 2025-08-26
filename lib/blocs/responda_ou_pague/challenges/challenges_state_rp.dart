abstract class ChallengesStateRP {}
class ChallengeInitialRP extends ChallengesStateRP {}
class ChallengeLoadingRP extends ChallengesStateRP {}
class ChallengeLoadedRP extends ChallengesStateRP {
  final Map<String, dynamic> challenge;
  ChallengeLoadedRP(this.challenge);
}
class ChallengeErrorRP extends ChallengesStateRP {
  final String message;
  ChallengeErrorRP(this.message);
}