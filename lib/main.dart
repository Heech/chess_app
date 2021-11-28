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

  PlayerColor _currentPlayer = PlayerColor.white;

  bool _isSelected(int col, int row) {
    if (_selected == null) return false;

    return _selected!.col == col && _selected!.row == row;
  }

  void _selectPiece(Position position) {
    final selectedPiece = _board[position.col][position.row];
    if (selectedPiece == null) return;

    if (selectedPiece.color != _currentPlayer) return;

    setState(() {
      _selected = position;
    });
  }

  void _move(int col, int row) {
    if (_selected == null) return;

    final currCol = _selected!.col;
    final currRow = _selected!.row;

    final selectedPiece = _board[currCol][currRow];
    if (selectedPiece == null) return;

    // can't move to current selected position
    if (col == currCol && row == currRow) {
      _clearSelected();
      return;
    }

    final validMoves =
        selectedPiece.getValidMoves(_board, Position(currCol, currRow));
    if (!_isValidMove(Position(col, row), validMoves)) {
      _clearSelected();
      return;
    }

    // clear previous position and selected
    // have to copy into a new row without the selected piece
    _board[currCol] = _board[currCol]
        .map((piece) => piece != selectedPiece ? piece : null)
        .toList();

    // move selected to new position and increment movement counter
    _board[col][row] = selectedPiece;
    selectedPiece.numberMoves += 1;

    _clearSelected();

    // switch player turn
    if (_currentPlayer == PlayerColor.white) {
      _currentPlayer = PlayerColor.black;
    } else {
      _currentPlayer = PlayerColor.white;
    }
  }

  void _clearSelected() {
    setState(() {
      _selected = null;
    });
  }

  bool _isValidMove(Position pos, List<Position> validPositions) {
    bool isValidMove = false;
    for (final validPos in validPositions) {
      if (validPos.col == pos.col && validPos.row == pos.row) {
        isValidMove = true;
        break;
      }
    }

    return isValidMove;
  }

  List<Position> _getValidMoves() {
    if (_selected == null) return [];

    final currCol = _selected!.col;
    final currRow = _selected!.row;

    final selectedPiece = _board[currCol][currRow];
    if (selectedPiece == null) return [];

    return selectedPiece.getValidMoves(_board, _selected as Position);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_currentPlayer == PlayerColor.white
            ? 'White to move'
            : 'Black to move'),
        Row(
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
                                              _selectPiece(Position(col, row));
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

                                  final isValidMove = _isValidMove(
                                    Position(col, row),
                                    _getValidMoves(),
                                  );

                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: _selected != null
                                          ? () {
                                              _move(col, row);
                                            }
                                          : null,
                                      child: Container(
                                        color:
                                            _isSelected(col, row) || isValidMove
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
  final ValidMoveChecker validMoveChecker;

  int numberMoves = 0;

  Piece({
    required this.color,
    required this.name,
    required this.display,
    required this.validMoveChecker,
  });

  factory Piece.white({
    required String name,
    required String display,
    required ValidMoveChecker validMoveChecker,
  }) =>
      Piece(
          color: PlayerColor.white,
          name: name,
          display: display,
          validMoveChecker: validMoveChecker);

  factory Piece.black({
    required String name,
    required String display,
    required ValidMoveChecker validMoveChecker,
  }) =>
      Piece(
          color: PlayerColor.black,
          name: name,
          display: display,
          validMoveChecker: validMoveChecker);

  List<Position> getValidMoves(List<List<Piece?>> board, Position position) {
    return validMoveChecker.getValidMoves(board, this, position);
  }

  bool get isWhite => color == PlayerColor.white;
}

class Pieces {
  static List<Piece> getWhiteBackRow() => [
        Piece.white(
          name: 'white rook',
          display: 'wr',
          validMoveChecker: RookValidMoveChecker(),
        ),
        Piece.white(
          name: 'white knight',
          display: 'wk',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.white(
          name: 'white bishop',
          display: 'wb',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.white(
          name: 'white queen',
          display: 'wq',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.white(
          name: 'white king',
          display: 'wK',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.white(
          name: 'white bishop',
          display: 'wb',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.white(
          name: 'white knight',
          display: 'wk',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.white(
          name: 'white rook',
          display: 'wr',
          validMoveChecker: RookValidMoveChecker(),
        ),
      ];

  static List<Piece> getWhiteFrontRow() => List.generate(
        8,
        (_) => Piece.white(
          name: 'white pawn',
          display: 'wp',
          validMoveChecker: PawnValidMoveChecker(),
        ),
      );

  static List<Piece> getBlackBackRow() => [
        Piece.black(
          name: 'black rook',
          display: 'br',
          validMoveChecker: RookValidMoveChecker(),
        ),
        Piece.black(
          name: 'black knight',
          display: 'bk',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.black(
          name: 'black bishop',
          display: 'bb',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.black(
          name: 'black queen',
          display: 'bq',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.black(
          name: 'black king',
          display: 'bK',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.black(
          name: 'black bishop',
          display: 'bb',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.black(
          name: 'black knight',
          display: 'bk',
          validMoveChecker: PawnValidMoveChecker(),
        ),
        Piece.black(
          name: 'black rook',
          display: 'br',
          validMoveChecker: RookValidMoveChecker(),
        ),
      ];

  static List<Piece> getBlackFrontRow() => List.generate(
        8,
        (_) => Piece.black(
          name: 'black pawn',
          display: 'bp',
          validMoveChecker: PawnValidMoveChecker(),
        ),
      );
}

abstract class ValidMoveChecker {
  List<Position> getValidMoves(
    List<List<Piece?>> board,
    Piece piece,
    Position position,
  );
}

class PawnValidMoveChecker implements ValidMoveChecker {
  @override
  List<Position> getValidMoves(
    List<List<Piece?>> board,
    Piece piece,
    Position position,
  ) {
    List<Position> validMoves = [];

    int col, row;

    col = piece.isWhite ? position.col - 1 : position.col + 1;
    row = position.row;
    if (_inBounds(col, row)) {
      final targetSquare = board[col][row];
      if (targetSquare == null) {
        validMoves.add(Position(col, row));
      }
    }

    if (piece.numberMoves < 1) {
      col = piece.isWhite ? position.col - 2 : position.col + 2;
      row = position.row;
      if (_inBounds(col, row)) {
        final targetSquare = board[col][row];
        if (targetSquare == null) {
          validMoves.add(Position(col, row));
        }
      }
    }

    col = piece.isWhite ? position.col - 1 : position.col + 1;
    row = piece.isWhite ? position.row + 1 : position.row - 1;
    if (_inBounds(col, row)) {
      final targetSquare = board[col][row];
      if (targetSquare != null && targetSquare.color != piece.color) {
        validMoves.add(Position(col, row));
      }
    }

    col = piece.isWhite ? position.col - 1 : position.col + 1;
    row = piece.isWhite ? position.row - 1 : position.row + 1;
    if (_inBounds(col, row)) {
      final targetSquare = board[col][row];
      if (targetSquare != null && targetSquare.color != piece.color) {
        validMoves.add(Position(col, row));
      }
    }

    return validMoves;
  }

  bool _inBounds(int col, int row) =>
      (col >= 0 && col <= 7 && row >= 0 && row <= 7);
}

class RookValidMoveChecker implements ValidMoveChecker {
  @override
  List<Position> getValidMoves(
    List<List<Piece?>> board,
    Piece piece,
    Position position,
  ) {
    List<Position> validMoves = [];

    validMoves
        .addAll(exploreUp(board, position.col, position.row - 1, piece.color));
    validMoves.addAll(
        exploreRight(board, position.col + 1, position.row, piece.color));
    validMoves.addAll(
        exploreDown(board, position.col, position.row + 1, piece.color));
    validMoves.addAll(
        exploreLeft(board, position.col - 1, position.row, piece.color));

    return validMoves;
  }

  List<Position> exploreUp(
    List<List<Piece?>> board,
    int col,
    int row,
    PlayerColor color,
  ) {
    if (!_inBounds(col, row)) return [];

    final targetSquare = board[col][row];
    if (targetSquare != null) {
      if (targetSquare.color == color) {
        return [];
      } else {
        return [Position(col, row)];
      }
    }

    List<Position> validMoves = [Position(col, row)];
    validMoves.addAll(exploreUp(board, col, row - 1, color));
    return validMoves;
  }

  List<Position> exploreDown(
    List<List<Piece?>> board,
    int col,
    int row,
    PlayerColor color,
  ) {
    if (!_inBounds(col, row)) return [];

    final targetSquare = board[col][row];
    if (targetSquare != null) {
      if (targetSquare.color == color) {
        return [];
      } else {
        return [Position(col, row)];
      }
    }

    List<Position> validMoves = [Position(col, row)];
    validMoves.addAll(exploreDown(board, col, row + 1, color));
    return validMoves;
  }

  List<Position> exploreRight(
    List<List<Piece?>> board,
    int col,
    int row,
    PlayerColor color,
  ) {
    if (!_inBounds(col, row)) return [];

    final targetSquare = board[col][row];
    if (targetSquare != null) {
      if (targetSquare.color == color) {
        return [];
      } else {
        return [Position(col, row)];
      }
    }

    List<Position> validMoves = [Position(col, row)];
    validMoves.addAll(exploreRight(board, col + 1, row, color));
    return validMoves;
  }

  List<Position> exploreLeft(
    List<List<Piece?>> board,
    int col,
    int row,
    PlayerColor color,
  ) {
    if (!_inBounds(col, row)) return [];

    final targetSquare = board[col][row];
    if (targetSquare != null) {
      if (targetSquare.color == color) {
        return [];
      } else {
        return [Position(col, row)];
      }
    }

    List<Position> validMoves = [Position(col, row)];
    validMoves.addAll(exploreLeft(board, col - 1, row, color));
    return validMoves;
  }

  bool _inBounds(int col, int row) =>
      (col >= 0 && col <= 7 && row >= 0 && row <= 7);
}
