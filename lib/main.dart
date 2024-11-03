import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int _rows = 20;
  final int _columns = 20;
  final _random = Random();

  List<Point<int>> _snake = [Point(10, 10)];
  Point<int>? _food;
  String _direction = 'right';
  bool _isGameOver = false;
  int _score = 0;

  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    _generateFood();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _generateFood() {
    _food = Point(
      _random.nextInt(_rows),
      _random.nextInt(_columns),
    );
  }

  void _moveSnake() {
    setState(() {
      Point<int> newHead;

      switch (_direction) {
        case 'up':
          newHead = Point(_snake.first.x, _snake.first.y - 1);
          break;
        case 'down':
          newHead = Point(_snake.first.x, _snake.first.y + 1);
          break;
        case 'left':
          newHead = Point(_snake.first.x - 1, _snake.first.y);
          break;
        case 'right':
        default:
          newHead = Point(_snake.first.x + 1, _snake.first.y);
      }

      if (_isGameOver || _checkCollision(newHead)) {
        _endGame();
      } else {
        _snake.insert(0, newHead);
        if (newHead == _food) {
          _score++;
          _generateFood();
        } else {
          _snake.removeLast();
        }
      }
    });
  }

  bool _checkCollision(Point<int> position) {
    return position.x < 0 ||
        position.x >= _columns ||
        position.y < 0 ||
        position.y >= _rows ||
        _snake.contains(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game | Score: $_score'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0) _changeDirection('down');
          if (details.delta.dy < 0) _changeDirection('up');
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0) _changeDirection('right');
          if (details.delta.dx < 0) _changeDirection('left');
        },
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
          ),
          itemCount: _rows * _columns,
          itemBuilder: (context, index) {
            final x = index % _columns;
            final y = index ~/ _columns;
            final point = Point(x, y);

            return Container(
              margin: EdgeInsets.all(1),
              color: _snake.contains(point)
                  ? Colors.green
                  : _food == point
                      ? Colors.red
                      : Colors.grey[300],
            );
          },
        ),
      ),
    );
  }

  void _changeDirection(String newDirection) {
    if ((_direction == 'up' && newDirection == 'down') ||
        (_direction == 'down' && newDirection == 'up') ||
        (_direction == 'left' && newDirection == 'right') ||
        (_direction == 'right' && newDirection == 'left')) {
      return;
    }
    setState(() {
      _direction = newDirection;
    });
  }

  void _startGame() {
    _gameTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      _moveSnake();
    });
  }

  void _endGame() {
    setState(() {
      _isGameOver = true;
      _gameTimer?.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text('Your score: $_score'),
            actions: [
              TextButton(
                child: Text('Restart'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _restartGame();
                },
              ),
            ],
          );
        },
      );
    });
  }

  void _restartGame() {
    setState(() {
      _snake = [Point(10, 10)];
      _direction = 'right';
      _isGameOver = false;
      _score = 0;
      _generateFood();
      _startGame();
    });
  }
}
