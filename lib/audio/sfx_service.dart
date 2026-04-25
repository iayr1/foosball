import 'package:audioplayers/audioplayers.dart';

class SfxService {
  SfxService._();

  static final SfxService instance = SfxService._();

  final AudioPlayer _slingPlayer = AudioPlayer();
  final AudioPlayer _strikerPlayer = AudioPlayer();

  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;

  Future<void> initialize() async {
    await _slingPlayer.setReleaseMode(ReleaseMode.stop);
    await _strikerPlayer.setReleaseMode(ReleaseMode.stop);
    await _slingPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _strikerPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  void setEnabled(bool value) {
    _isEnabled = value;
    if (!value) {
      _slingPlayer.stop();
      _strikerPlayer.stop();
    }
  }

  Future<void> playSlingStretch() async {
    if (!_isEnabled) return;
    await _slingPlayer.stop();
    await _slingPlayer.play(
      AssetSource('sound_effects/slingstretchsound.mp3'),
      volume: 1.0,
    );
  }

  Future<void> playStriker() async {
    if (!_isEnabled) return;
    await _strikerPlayer.stop();
    await _strikerPlayer.play(
      AssetSource('sound_effects/strikersound.mp3'),
      volume: 1.0,
    );
  }

  Future<void> dispose() async {
    await _slingPlayer.dispose();
    await _strikerPlayer.dispose();
  }
}
