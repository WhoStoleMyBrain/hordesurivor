import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/horde_game.dart';

void main() {
  runApp(const HordeSurvivorApp());
}

class HordeSurvivorApp extends StatelessWidget {
  const HordeSurvivorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: GameWidget(
        game: HordeGame(),
      ),
    );
  }
}
