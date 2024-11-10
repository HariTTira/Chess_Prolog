:- dynamic piece/3.
:- discontiguous valid_move/5.

piece(wp, 6, 0).
piece(wp, 6, 1).
piece(wp, 6, 2).
piece(wp, 6, 3).
piece(wp, 6, 4).
piece(wp, 6, 5).
piece(wp, 6, 6).
piece(wp, 6, 7).

piece(bp, 1, 0).
piece(bp, 1, 1).
piece(bp, 1, 2).
piece(bp, 1, 3).
piece(bp, 1, 4).
piece(bp, 1, 5).
piece(bp, 1, 6).
piece(bp, 1, 7).

piece(wR, 7, 0). 
piece(wR, 7, 7).

piece(bR, 0, 0).
piece(bR, 0, 7).

piece(wN, 7, 1).
piece(wN, 7, 6).

piece(bN, 0, 1).
piece(bN, 0, 6).

piece(wB, 7, 2).
piece(wB, 7, 5).

piece(bB, 0, 2).
piece(bB, 0, 5).

piece(wQ, 7, 3).
piece(bQ, 0, 3).

piece(wK, 7, 4).
piece(bK, 0, 4).

% Pawn move
% White Pawn
valid_move(wp, X, Y, X2, Y2) :- 
    (X2 is X - 1, Y2 = Y),
    piece(wp, X, Y),
    \+ piece(_, X2, Y2).

valid_move(wp, X, Y, X2, Y2) :- 
    (X2 is X - 2, Y2 = Y),
    X = 6,
    piece(wp, X, Y),
    \+ piece(bp, X2, Y2).

valid_move(wp, X, Y, X2, Y2) :-
    (   X2 is X - 1, Y2 is Y + 1
    ;   X2 is X - 1, Y2 is Y - 1
    ),
    (   piece(bp, X2, Y2)  % Capturing black pawn
    ;   piece(bR, X2, Y2)  % Capturing black rook
    ;   piece(bN, X2, Y2)  % Capturing black knight
    ;   piece(bB, X2, Y2)  % Capturing black bishop
    ;   piece(bQ, X2, Y2)  % Capturing black queen
    ;   piece(bK, X2, Y2)  % Capturing black king (if allowed)
    ),
    piece(wp, X, Y),  % White pawn is at (X, Y)
    retract(piece(_, X2, Y2)),  % Remove captured piece
    assert(piece(wp, X2, Y2)).  % Move white pawn to (X2, Y2)


% Black Pawn
valid_move(bp, X, Y, X2, Y2) :- 
    (X2 is X + 1, Y2 = Y),
    piece(bp, X, Y),
    \+ piece(_, X2, Y2).  

valid_move(bp, X, Y, X2, Y2) :- 
    (X2 is X + 2, Y2 = Y),
    X = 1,
    piece(bp, X, Y),
    \+ piece(_, X2, Y2).  

valid_move(bp, X, Y, X2, Y2) :-
    (   X2 is X + 1, Y2 is Y + 1  % Diagonal move down-left
    ;   X2 is X + 1, Y2 is Y - 1  % Diagonal move down-right
    ),
    % Check if the destination contains a white piece
    (   piece(wp, X2, Y2)  % Capturing white pawn
    ;   piece(wR, X2, Y2)  % Capturing white rook
    ;   piece(wN, X2, Y2)  % Capturing white knight
    ;   piece(wB, X2, Y2)  % Capturing white bishop
    ;   piece(wQ, X2, Y2)  % Capturing white queen
    ;   piece(wK, X2, Y2)  % Capturing white king (if allowed)
    ),
    piece(bp, X, Y),  % Black pawn is at (X, Y)
    retract(piece(_, X2, Y2)),  % Remove the captured white piece
    assert(piece(bp, X2, Y2)).  % Move black pawn to (X2, Y2)

% Rook move
% White Rook movement
valid_move(wR, X, Y, X2, Y2) :-
    (X2 = X; Y2 = Y),
    clear_path(wR, X, Y, X2, Y2),
    piece(wR, X, Y),
    (   \+ piece(_, X2, Y2)
    ;   piece(bp, X2, Y2),
        retract(piece(bp, X2, Y2))
    ;   piece(bR, X2, Y2),
        retract(piece(bR, X2, Y2))
    ;   piece(bN, X2, Y2),
        retract(piece(bN, X2, Y2))
    ;   piece(bB, X2, Y2),
        retract(piece(bB, X2, Y2))
    ;   piece(bQ, X2, Y2),
        retract(piece(bQ, X2, Y2))
    ;   piece(bK, X2, Y2),
        retract(piece(bK, X2, Y2))
    ).
% Black Rook movement
valid_move(bR, X, Y, X2, Y2) :-
    (X2 = X; Y2 = Y),
    clear_path(bR, X, Y, X2, Y2),
    piece(bR, X, Y),
    (   \+ piece(_, X2, Y2)
    ;   piece(wp, X2, Y2),
        retract(piece(wp, X2, Y2))
    ;   piece(wR, X2, Y2),
        retract(piece(wR, X2, Y2))
    ;   piece(wN, X2, Y2),
        retract(piece(wN, X2, Y2))
    ;   piece(wB, X2, Y2),
        retract(piece(wB, X2, Y2))
    ;   piece(wQ, X2, Y2),
        retract(piece(wQ, X2, Y2))
    ;   piece(wK, X2, Y2),
        retract(piece(wK, X2, Y2))
    ).

clear_path(Piece, X, Y, X2, Y2) :-
    X = X2,
    (Y2 > Y -> NextY is Y + 1; Y2 < Y -> NextY is Y - 1),
    clear_path_horizontal(Piece, X, NextY, Y2).

clear_path(Piece, X, Y, X2, Y2) :-
    Y = Y2,
    (X2 > X -> NextX is X + 1; X2 < X -> NextX is X - 1),
    clear_path_vertical(Piece, NextX, Y2, X2).

clear_path_horizontal(_, _, Y, Y2) :- 
    Y = Y2.

clear_path_horizontal(Piece, X, Y, Y2) :-
    Y \= Y2,
    \+ piece(_, X, Y),
    (   Y2 > Y -> NextY is Y + 1; Y2 < Y -> NextY is Y - 1),
    clear_path_horizontal(Piece, X, NextY, Y2).

clear_path_vertical(_, X, _, X2) :- 
    X = X2.

clear_path_vertical(Piece, X, Y, X2) :-
    X \= X2,
    \+ piece(_, X, Y),
    (   X2 > X -> NextX is X + 1; X2 < X -> NextX is X - 1),
    clear_path_vertical(Piece, NextX, Y, X2).

% Knight move
valid_move(wN, X, Y, X2, Y2) :- 
    piece(wN, X, Y),
    (   (X2 is X - 2, Y2 is Y - 1)
    ;   (X2 is X - 2, Y2 is Y + 1)
    ;   (X2 is X - 1, Y2 is Y - 2)
    ;   (X2 is X - 1, Y2 is Y + 2)
    ;   (X2 is X + 1, Y2 is Y - 2)
    ;   (X2 is X + 1, Y2 is Y + 2)
    ;   (X2 is X + 2, Y2 is Y - 1)
    ;   (X2 is X + 2, Y2 is Y + 1)
    ),
    (   \+ piece(_, X2, Y2)  % destination is empty
    ;   piece(bp, X2, Y2),    % destination contains a black pawn
        retract(piece(bp, X2, Y2))  % capture the black pawn
    ;   piece(bR, X2, Y2),    % destination contains a black rook
        retract(piece(bR, X2, Y2))  % capture the black rook
    ;   piece(bN, X2, Y2),    % destination contains a black knight
        retract(piece(bN, X2, Y2))  % capture the black knight
    ;   piece(bQ, X2, Y2),    % destination contains a black queen
        retract(piece(bQ, X2, Y2))  % capture the black queen
    ;   piece(bB, X2, Y2),    % destination contains a black bishop
        retract(piece(bB, X2, Y2))  % capture the black bishop
    ;   piece(bK, X2, Y2),    % destination contains a black king
        retract(piece(bK, X2, Y2))  % capture the black king
    ).


valid_move(bN, X, Y, X2, Y2) :- 
    piece(bN, X, Y),
    (   (X2 is X - 2, Y2 is Y - 1)
    ;   (X2 is X - 2, Y2 is Y + 1)
    ;   (X2 is X - 1, Y2 is Y - 2)
    ;   (X2 is X - 1, Y2 is Y + 2)
    ;   (X2 is X + 1, Y2 is Y - 2)
    ;   (X2 is X + 1, Y2 is Y + 2)
    ;   (X2 is X + 2, Y2 is Y - 1)
    ;   (X2 is X + 2, Y2 is Y + 1)
    ),
    (   \+ piece(_, X2, Y2)  % destination is empty
    ;   piece(wp, X2, Y2),    % destination contains a white pawn
        retract(piece(wp, X2, Y2))  % capture the white pawn
    ;   piece(wR, X2, Y2),    % destination contains a white rook
        retract(piece(wR, X2, Y2))  % capture the white rook
    ;   piece(wN, X2, Y2),    % destination contains a white knight
        retract(piece(wN, X2, Y2))  % capture the white knight
    ;   piece(wQ, X2, Y2),    % destination contains a white queen
        retract(piece(wQ, X2, Y2))  % capture the white queen
    ;   piece(wB, X2, Y2),    % destination contains a white bishop
        retract(piece(wB, X2, Y2))  % capture the white bishop
    ;   piece(wK, X2, Y2),    % destination contains a white king
        retract(piece(wK, X2, Y2))  % capture the white king
    ).

% White Bishop movement
valid_move(wB, X, Y, X2, Y2) :- 
    piece(wB, X, Y),
    abs(X2 - X) =:= abs(Y2 - Y),  % Bishop moves diagonally
    clear_path_bishop(wB, X, Y, X2, Y2),
    (   \+ piece(_, X2, Y2)  % destination is empty
    ;   (piece(bp, X2, Y2); piece(bR, X2, Y2); piece(bN, X2, Y2); piece(bQ, X2, Y2); piece(bB, X2, Y2); piece(bK, X2, Y2)),  % destination contains a black piece
        retract(piece(_, X2, Y2))  % capture the black piece
    ).

valid_move(bB, X, Y, X2, Y2) :- 
    piece(bB, X, Y),
    abs(X2 - X) =:= abs(Y2 - Y),  % Bishop moves diagonally
    clear_path_bishop(bB, X, Y, X2, Y2),
    (   \+ piece(_, X2, Y2)  % destination is empty
    ;   (piece(wp, X2, Y2); piece(wR, X2, Y2); piece(wN, X2, Y2); piece(wQ, X2, Y2); piece(wB, X2, Y2); piece(wK, X2, Y2)),  % destination contains a white piece
        retract(piece(_, X2, Y2))  % capture the white piece
    ).

clear_path_bishop(Piece, X, Y, X2, Y2) :-
    abs(X2 - X) =:= abs(Y2 - Y),  % Ensure the move is diagonal
    (X2 > X -> StepX = 1 ; X2 < X -> StepX = -1),
    (Y2 > Y -> StepY = 1 ; Y2 < Y -> StepY = -1),
    clear_path_diagonal(Piece, X, Y, X2, Y2, StepX, StepY).

% Base case: destination reached, no piece in the way
clear_path_diagonal(_, X, Y, X2, Y2, _, _) :- 
    X =:= X2, Y =:= Y2.

% Recursive case: Check along the diagonal path
clear_path_diagonal(Piece, X, Y, X2, Y2, StepX, StepY) :- 
    NextX is X + StepX, 
    NextY is Y + StepY,
    (NextX =:= X2, NextY =:= Y2 -> true ;  % Reached destination
     \+ piece(_, NextX, NextY),  % No piece blocking
     clear_path_diagonal(Piece, NextX, NextY, X2, Y2, StepX, StepY)).


% White Queen movement
valid_move(wQ, X, Y, X2, Y2) :-
    piece(wQ, X, Y),
    (   X = X2; Y = Y2),  % Rook-like movement (horizontal or vertical)
    clear_path(wQ, X, Y, X2, Y2),
    (   \+ piece(_, X2, Y2)  % destination is empty
    ;   (piece(bp, X2, Y2); piece(bR, X2, Y2); piece(bN, X2, Y2); piece(bQ, X2, Y2); piece(bB, X2, Y2); piece(bK, X2, Y2)),  % destination contains a black piece
        retract(piece(_, X2, Y2))  % capture the black piece
    ).
  
valid_move(wQ, X, Y, X2, Y2) :- 
    piece(wQ, X, Y),
    abs(X2 - X) =:= abs(Y2 - Y),  % Bishop-like diagonal movement
    clear_path_bishop(wQ, X, Y, X2, Y2),
    (   \+ piece(_, X2, Y2)  % destination is empty
    ;   (piece(bp, X2, Y2); piece(bR, X2, Y2); piece(bN, X2, Y2); piece(bQ, X2, Y2); piece(bB, X2, Y2); piece(bK, X2, Y2)),  % destination contains a black piece
        retract(piece(_, X2, Y2))  % capture the black piece
    ).

% Black Queen movement
valid_move(bQ, X, Y, X2, Y2) :- 
    piece(bQ, X, Y),
    (   X = X2; Y = Y2),  % Rook-like movement (horizontal or vertical)
    clear_path(bQ, X, Y, X2, Y2),
    (   \+ piece(_, X2, Y2)  % destination is empty
    ;   (piece(wp, X2, Y2); piece(wR, X2, Y2); piece(wN, X2, Y2); piece(wQ, X2, Y2); piece(wB, X2, Y2); piece(wK, X2, Y2)),  % destination contains a white piece
        retract(piece(_, X2, Y2))  % capture the white piece
    ).

valid_move(bQ, X, Y, X2, Y2) :- 
    piece(bQ, X, Y),
    abs(X2 - X) =:= abs(Y2 - Y),  % Bishop-like diagonal movement
    clear_path_bishop(bQ, X, Y, X2, Y2),
    (   \+ piece(_, X2, Y2)  % destination is empty
    ;   (piece(wp, X2, Y2); piece(wR, X2, Y2); piece(wN, X2, Y2); piece(wQ, X2, Y2); piece(wB, X2, Y2); piece(wK, X2, Y2)),  % destination contains a white piece
        retract(piece(_, X2, Y2))  % capture the white piece
    ).

% White King movement (with capture ability)
valid_move(wK, X, Y, X2, Y2) :-
    piece(wK, X, Y),
    (   (X2 is X + 1, Y2 is Y)
    ;   (X2 is X - 1, Y2 is Y)
    ;   (X2 is X, Y2 is Y + 1)
    ;   (X2 is X, Y2 is Y - 1)
    ;   (X2 is X + 1, Y2 is Y + 1)
    ;   (X2 is X + 1, Y2 is Y - 1)
    ;   (X2 is X - 1, Y2 is Y + 1)
    ;   (X2 is X - 1, Y2 is Y - 1)
    ),
    (   \+ piece(_, X2, Y2)  % destination is empty
    ;   piece(bp, X2, Y2),    % destination contains a black pawn
        retract(piece(bp, X2, Y2))  % capture the black pawn
    ;   piece(bR, X2, Y2),    % destination contains a black rook
        retract(piece(bR, X2, Y2))  % capture the black rook
    ;   piece(bN, X2, Y2),    % destination contains a black knight
        retract(piece(bN, X2, Y2))  % capture the black knight
    ;   piece(bB, X2, Y2),    % destination contains a black bishop
        retract(piece(bB, X2, Y2))  % capture the black bishop
    ;   piece(bQ, X2, Y2),    % destination contains a black queen
        retract(piece(bQ, X2, Y2))  % capture the black queen
    ;   piece(bK, X2, Y2),    % destination contains a black king
        retract(piece(bK, X2, Y2))  % capture the black king
    ).


% Black King movement (with capture ability)
valid_move(bK, X, Y, X2, Y2) :-
    piece(bK, X, Y),
    (   (X2 is X + 1, Y2 is Y)
    ;   (X2 is X - 1, Y2 is Y)
    ;   (X2 is X, Y2 is Y + 1)
    ;   (X2 is X, Y2 is Y - 1)
    ;   (X2 is X + 1, Y2 is Y + 1)
    ;   (X2 is X + 1, Y2 is Y - 1)
    ;   (X2 is X - 1, Y2 is Y + 1)
    ;   (X2 is X - 1, Y2 is Y - 1)
    ),
    (   \+ piece(_, X2, Y2)  % destination is empty
    ;   piece(wp, X2, Y2),    % destination contains a white pawn
        retract(piece(wp, X2, Y2))  % capture the white pawn
    ;   piece(wR, X2, Y2),    % destination contains a white rook
        retract(piece(wR, X2, Y2))  % capture the white rook
    ;   piece(wN, X2, Y2),    % destination contains a white knight
        retract(piece(wN, X2, Y2))  % capture the white knight
    ;   piece(wB, X2, Y2),    % destination contains a white bishop
        retract(piece(wB, X2, Y2))  % capture the white bishop
    ;   piece(wQ, X2, Y2),    % destination contains a white queen
        retract(piece(wQ, X2, Y2))  % capture the white queen
    ;   piece(wK, X2, Y2),    % destination contains a white king
        retract(piece(wK, X2, Y2))  % capture the white king
    ).

move_valid(Piece, X1, Y1, X2, Y2) :- valid_move(Piece, X1, Y1, X2, Y2).

make_move(Piece, X1, Y1, X2, Y2) :- 
    valid_move(Piece, X1, Y1, X2, Y2),
    retract(piece(Piece, X1, Y1)),
    assertz(piece(Piece, X2, Y2)).

move(Piece, X1, Y1, X2, Y2) :- 
    make_move(Piece, X1, Y1, X2, Y2).

valid_moves(Piece, X, Y, ValidMoves) :-
    findall([EndRow, EndCol], valid_move(Piece, X, Y, EndRow, EndCol), ValidMoves).

