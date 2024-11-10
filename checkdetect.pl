:- [piece_rule].  % Ensure the path is correct

:- dynamic piece/3.

in_check(bK) :-
    piece(bK, X, Y),
    piece(WhitePiece, X2, Y2),
    member(WhitePiece, [wp, wR, wN, wB, wQ, wK]),
    valid_move(WhitePiece, X2, Y2, X, Y).

in_check(wK) :-
    piece(wK, X, Y),
    piece(BlackPiece, X2, Y2),
    member(BlackPiece, [bp, bR, bN, bB, bQ, bK]),
    valid_move(BlackPiece, X2, Y2, X, Y).

safe_position_wk(_, X, Y) :-
    \+ (piece(OpponentPiece, X2, Y2),
        member(OpponentPiece, [bp, bR, bN, bB, bQ, bK]),
        valid_move(OpponentPiece, X2, Y2, X, Y)
    ).

safe_position_bk(_, X, Y) :-
    \+ (piece(OpponentPiece, X2, Y2),
        member(OpponentPiece, [wp, wR, wN, wB, wQ, wK]),
        valid_move(OpponentPiece, X2, Y2, X, Y)
    ).

escape_check(bK) :-
    piece(bK, X, Y),
    (   X2 is X + 1, Y2 is Y
    ;   X2 is X - 1, Y2 is Y
    ;   X2 is X, Y2 is Y + 1
    ;   X2 is X, Y2 is Y - 1
    ;   X2 is X + 1, Y2 is Y + 1
    ;   X2 is X + 1, Y2 is Y - 1
    ;   X2 is X - 1, Y2 is Y + 1
    ;   X2 is X - 1, Y2 is Y - 1
    ),
    safe_position_bk(bK, X2, Y2).

escape_check(wK) :-
    piece(wK, X, Y),
    (   X2 is X + 1, Y2 is Y
    ;   X2 is X - 1, Y2 is Y
    ;   X2 is X, Y2 is Y + 1
    ;   X2 is X, Y2 is Y - 1
    ;   X2 is X + 1, Y2 is Y + 1
    ;   X2 is X + 1, Y2 is Y - 1
    ;   X2 is X - 1, Y2 is Y + 1
    ;   X2 is X - 1, Y2 is Y - 1
    ),
    safe_position_wk(wK, X2, Y2).

checkmate(bK) :-
    in_check(bK),
    \+ escape_check(bK).

checkmate(wK) :-
    in_check(wK),
    \+ escape_check(wK).
