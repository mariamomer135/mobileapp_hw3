import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.blue.shade900, // Dark blue background
        ),
        home: CardMatchingGame(),
      ),
    );
  }
}

class GameProvider extends ChangeNotifier {
  List<CardModel> cards = [];
  CardModel? firstSelected;
  bool isProcessing = false;

  GameProvider() {
    _initializeGame();
  }

  void _initializeGame() {
    List<String> emojis = ['🕷️', '🕸️', '💥', '🦸‍♂️', '🏹', '⚡', '🛡️', '💀'];
    emojis = [...emojis, ...emojis]; // Duplicate for matching pairs
    emojis.shuffle(Random());
    cards = List.generate(emojis.length, (index) => CardModel(emojis[index]));
    notifyListeners();
  }

  void flipCard(CardModel card) {
    if (isProcessing || card.isMatched || card.isFaceUp) return;

    card.isFaceUp = true;
    notifyListeners();

    if (firstSelected == null) {
      firstSelected = card;
    } else {
      isProcessing = true;
      Future.delayed(const Duration(seconds: 1), () {
        if (firstSelected!.emoji == card.emoji) {
          firstSelected!.isMatched = true;
          card.isMatched = true;
        } else {
          firstSelected!.isFaceUp = false;
          card.isFaceUp = false;
        }
        firstSelected = null;
        isProcessing = false;
        notifyListeners();
      });
    }
  }
}

class CardModel {
  final String emoji;
  bool isFaceUp;
  bool isMatched;

  CardModel(this.emoji, {this.isFaceUp = false, this.isMatched = false});
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marvel Card Matching"),
        backgroundColor: Colors.red.shade900, // Spider-Man red
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: game.cards.length,
            itemBuilder: (context, index) {
              return CardWidget(card: game.cards[index]);
            },
          );
        },
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;

  const CardWidget({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<GameProvider>().flipCard(card),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationYTransition(turns: animation, child: child);
        },
        child: card.isFaceUp || card.isMatched
            ? Container(
                key: ValueKey(card.emoji),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white, // Face-up card color
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 3), // Blue border
                ),
                child: Text(
                  card.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              )
            : Container(
                key: ValueKey("back"),
                decoration: BoxDecoration(
                  color: Colors.red.shade900, // Spider-Man red for face-down cards
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
      ),
    );
  }
}

class RotationYTransition extends AnimatedWidget {
  final Widget child;
  final Animation<double> turns;

  const RotationYTransition({Key? key, required this.turns, required this.child})
      : super(key: key, listenable: turns);

  @override
  Widget build(BuildContext context) {
    final value = turns.value * pi;
    return Transform(
      transform: Matrix4.rotationY(value),
      alignment: Alignment.center,
      child: child,
    );
  }
}
