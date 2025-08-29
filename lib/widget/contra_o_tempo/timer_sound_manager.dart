import 'package:audioplayers/audioplayers.dart';
import 'package:jogoteca/constants/app_constants.dart';

class TimerSoundManager {
  final AudioPlayer _bipPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _alarmPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);


  Future<void> onTick(int timeLeft) async {
    if (timeLeft <= 10 && timeLeft > 0) {
      await _bipPlayer.play(AssetSource(AppConstants.bipSound));
    }
  }

  Future<void> playTimeUp() async {
    await _alarmPlayer.play(AssetSource(AppConstants.alarmClockSound));

    // Para o alarme após 5 segundos
    Future.delayed(const Duration(seconds: 5), () async {
      await _alarmPlayer.stop();
    });
  }

  Future<void> stopAll() async {
    await _bipPlayer.stop();
    await _alarmPlayer.stop();
  }

  Future<void> dispose() async {
    await _bipPlayer.dispose();
    await _alarmPlayer.dispose();
  }
}
