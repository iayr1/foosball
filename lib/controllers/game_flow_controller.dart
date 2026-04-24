import '../models/game_mode.dart';

class GameFlowController {
  GameMode? selectedMode;

  void setMode(GameMode mode) {
    selectedMode = mode;
  }
}
