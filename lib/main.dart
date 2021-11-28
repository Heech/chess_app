import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(title: 'Chess App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade50,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: ChessBoard(),
        ),
      ),
    );
  }
}

class ChessBoard extends StatefulWidget {
  const ChessBoard({Key? key}) : super(key: key);

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  final List<List<Piece?>> _board = [
    Pieces.getBlackBackRow(),
    Pieces.getBlackFrontRow(),
    [null, null, null, null, null, null, null, null],
    [null, null, null, null, null, null, null, null],
    [null, null, null, null, null, null, null, null],
    [null, null, null, null, null, null, null, null],
    Pieces.getWhiteFrontRow(),
    Pieces.getWhiteBackRow(),
  ];

  Position? _selected;

  bool _isSelected(int col, int row) {
    if (_selected == null) return false;

    return _selected!.col == col && _selected!.row == row;
  }

  void _move(int col, int row) {
    if (_selected == null) return;

    final currCol = _selected!.col;
    final currRow = _selected!.row;

    // can't move to current selected position
    if (col == currCol && row == currRow) return;

    final piece = _board[currCol][_selected!.row];
    if (piece == null) return;

    final targetPiece = _board[col][row];
    final bool isEmpty = targetPiece == null;

    // can't take same color piece
    if (!isEmpty && targetPiece.color == piece.color) return;

    _board[col][row] = piece;

    _board[_selected!.col][_selected!.row] = null;
    _selected = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('left side'),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Column(
                  children: _board.asMap().entries.map(
                    (entry) {
                      final col = entry.key;
                      final startWhite = col.isEven;
                      return Flexible(
                        child: Row(
                          children: entry.value.asMap().entries.map(
                            (entry) {
                              final row = entry.key;
                              final Color color = row.isEven == startWhite
                                  ? Colors.white
                                  : Colors.black;

                              final piece = entry.value;

                              Widget? child;

                              if (piece != null) {
                                child = GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _selected == null
                                      ? () {
                                          setState(() {
                                            _selected = Position(col, row);
                                          });
                                        }
                                      : null,
                                  child: Center(
                                    child: Text(
                                      piece.display,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 30.0,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Expanded(
                                child: GestureDetector(
                                  onTap: _selected != null
                                      ? () {
                                          _move(col, row);
                                        }
                                      : null,
                                  child: Container(
                                    color: _isSelected(col, row)
                                        ? Colors.orange.shade100
                                        : color,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Position {
  final int col;
  final int row;

  const Position(this.col, this.row);
}

enum PlayerColor { white, black }

class Piece {
  final PlayerColor color;
  final String name;
  final String display;

  const Piece({
    required this.color,
    required this.name,
    required this.display,
  });

  factory Piece.white({
    required String name,
    required String display,
  }) =>
      Piece(
        color: PlayerColor.white,
        name: name,
        display: display,
      );

  factory Piece.black({
    required String name,
    required String display,
  }) =>
      Piece(
        color: PlayerColor.black,
        name: name,
        display: display,
      );

class Pieces {
  static List<Piece> getWhiteBackRow() => [
        Piece.white(name: 'white rook', display: 'wr'),
        Piece.white(name: 'white knight', display: 'wk'),
        Piece.white(name: 'white bishop', display: 'wb'),
        Piece.white(name: 'white queen', display: 'wq'),
        Piece.white(name: 'white king', display: 'wK'),
        Piece.white(name: 'white bishop', display: 'wb'),
        Piece.white(name: 'white knight', display: 'wk'),
        Piece.white(name: 'white rook', display: 'wr'),
      ];

  static List<Piece> getWhiteFrontRow() => List.generate(
        8,
        (_) => Piece.white(name: 'white pawn', display: 'wp'),
      );

  static List<Piece> getBlackBackRow() => [
        Piece.black(name: 'black rook', display: 'br'),
        Piece.black(name: 'black knight', display: 'bk'),
        Piece.black(name: 'black bishop', display: 'bb'),
        Piece.black(name: 'black queen', display: 'bq'),
        Piece.black(name: 'black king', display: 'bK'),
        Piece.black(name: 'black bishop', display: 'bb'),
        Piece.black(name: 'black knight', display: 'bk'),
        Piece.black(name: 'black rook', display: 'br'),
      ];

  static List<Piece> getBlackFrontRow() => List.generate(
        8,
        (_) => Piece.black(name: 'black pawn', display: 'bp'),
      );
}
}
