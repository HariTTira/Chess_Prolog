import pygame as p
import ChessEngine
# from pyswip import Prolog

# prolog = Prolog()
# prolog.consult("piece_rule.pl")

WIDTH = HEIGHT = 512
DIMENSION = 8
SQ_SIZE = HEIGHT // DIMENSION
MAX_FPS = 15
IMAGES = {}
TOP_MARGIN = 50
def loadImages():
    pieces = ['wp', 'bp', 'wR', 'wN', 'wB', 'wQ', 'wK', 'bR', 'bN', 'bB', 'bQ', 'bK']
    for piece in pieces:
        IMAGES[piece] = p.transform.scale(p.image.load("Images/"+ piece +".png"),(SQ_SIZE, SQ_SIZE))

def main():
    p.init()
    screen = p.display.set_mode((WIDTH, HEIGHT + TOP_MARGIN))
    clock = p.time.Clock()
    font = p.font.SysFont(None, 36)
    screen.fill(p.Color("white"))
    gs = ChessEngine.GameState()
    loadImages()
    running = True
    sqSelected = ()
    playerClicks = [] #keep track plater clicks(two tuple)
    while running:
        for e in p.event.get():
            if e.type == p.QUIT:
                running = False
            elif e.type == p.MOUSEBUTTONDOWN:
                location = p.mouse.get_pos()

                if location[1] < TOP_MARGIN:
                    print("Nothing Here")
                    continue

                col = location[0]//SQ_SIZE
                row = (location[1] - TOP_MARGIN) // SQ_SIZE
                if sqSelected == (row,col):
                    sqSelected = ()
                    playerClicks = []
                elif len(playerClicks) == 0 and gs.board[row][col] == "--":
                    print("Empty square clicked, no piece to select")
                else:
                    sqSelected = (row, col)
                    playerClicks.append(sqSelected)
                    print(sqSelected)
                if len(playerClicks) == 2:
                    move = ChessEngine.Move(playerClicks[0], playerClicks[1], gs.board)
                    print(move.getChessNotation())
                    if gs.makeMove(move):
                        gs.makeMove(move)
                        animateMove(move, screen, gs.board, clock)
                    if gs.makeMove(move) == "same_color":
                        playerClicks = [playerClicks[1]]
                        sqSelected = playerClicks[0]
                    else:
                        sqSelected = ()
                        playerClicks = []

                    for i in range(8):
                        print(gs.board[i])

        screen.fill(p.Color("white"))

        turn = whoseMove(gs)
        turn_text = font.render(f"{turn}'s Turn", True, p.Color("black"))
        text_rect = turn_text.get_rect(center=(WIDTH // 2, TOP_MARGIN // 2))
        screen.blit(turn_text, text_rect)

        drawGameState(screen, gs, sqSelected)
        clock.tick(MAX_FPS)
        p.display.flip()

def whoseMove(gs):
    if gs.whiteToMove:
        return "White"
    else:
        return "Black"

def highlightsquare(screen, gs, sqSelected):
    if sqSelected != ():
        row, col = sqSelected
        piece = gs.board[row][col]
        
        if piece != "--":
            # Highlight the selected piece square
            s = p.Surface((SQ_SIZE, SQ_SIZE))
            s.set_alpha(100)  # Transparency level for the highlight
            s.fill(p.Color('blue'))  # Change to desired color (blue for selected square)
            screen.blit(s, (col * SQ_SIZE, row * SQ_SIZE + TOP_MARGIN))  # Offset by TOP_MARGIN
            
            valid_moves = []
            piece_type = piece[0]  # 'w' or 'b'
            # Define the valid moves for each piece type
            if piece[1] == 'R':  # Rook
                # Horizontal moves (right)
                for i in range(col + 1, 8):  # Move right along the row
                    if gs.board[row][i] != "--":  # If there's a piece
                        if gs.board[row][i][0] != piece[0]:  # If the piece is opposite
                            s.fill(p.Color('red'))  # Color for the capture move (red)
                            screen.blit(s, (i * SQ_SIZE, row * SQ_SIZE + TOP_MARGIN))
                        break  # Stop at the first piece
                    s.fill(p.Color('yellow'))  # Color for valid moves (yellow)
                    screen.blit(s, (i * SQ_SIZE, row * SQ_SIZE + TOP_MARGIN))

                # Horizontal moves (left)
                for i in range(col - 1, -1, -1):  # Move left along the row
                    if gs.board[row][i] != "--":  # If there's a piece
                        if gs.board[row][i][0] != piece[0]:  # If the piece is opposite
                            s.fill(p.Color('red'))  # Color for the capture move (red)
                            screen.blit(s, (i * SQ_SIZE, row * SQ_SIZE + TOP_MARGIN))
                        break  # Stop at the first piece
                    s.fill(p.Color('yellow'))  # Color for valid moves (yellow)
                    screen.blit(s, (i * SQ_SIZE, row * SQ_SIZE + TOP_MARGIN))

                # Vertical moves (down)
                for i in range(row + 1, 8):  # Move down along the column
                    if gs.board[i][col] != "--":  # If there's a piece
                        if gs.board[i][col][0] != piece[0]:  # If the piece is opposite
                            s.fill(p.Color('red'))  # Color for the capture move (red)
                            screen.blit(s, (col * SQ_SIZE, i * SQ_SIZE + TOP_MARGIN))
                        break  # Stop at the first piece
                    s.fill(p.Color('yellow'))  # Color for valid moves (yellow)
                    screen.blit(s, (col * SQ_SIZE, i * SQ_SIZE + TOP_MARGIN))

                # Vertical moves (up)
                for i in range(row - 1, -1, -1):  # Move up along the column
                    if gs.board[i][col] != "--":  # If there's a piece
                        if gs.board[i][col][0] != piece[0]:  # If the piece is opposite
                            s.fill(p.Color('red'))  # Color for the capture move (red)
                            screen.blit(s, (col * SQ_SIZE, i * SQ_SIZE + TOP_MARGIN))
                        break  # Stop at the first piece
                    s.fill(p.Color('yellow'))  # Color for valid moves (yellow)
                    screen.blit(s, (col * SQ_SIZE, i * SQ_SIZE + TOP_MARGIN))

            if piece[1] == 'p':  # Pawn
                direction = 1 if piece[0] == 'b' else -1  # White moves up, Black moves down
                
                # Pawn capture moves (diagonal)
                for i in [-1, 1]:  # Check both diagonals for capturing
                    new_row = row + direction
                    new_col = col + i
                    if 0 <= new_row < 8 and 0 <= new_col < 8:  # Ensure new_row and new_col are within bounds
                        if gs.board[new_row][new_col] != "--":  # If there's a piece
                            if gs.board[new_row][new_col][0] != piece[0]:  # If it's opposite color
                                s.fill(p.Color('red'))  # Color for the capture move (red)
                                screen.blit(s, (new_col * SQ_SIZE, new_row * SQ_SIZE + TOP_MARGIN))

                new_row = row + direction
                if 0 <= new_row < 8 and gs.board[new_row][col] == "--":  # Check if the square is empty and within bounds
                    s.fill(p.Color('yellow'))  # Color for valid move (yellow)
                    screen.blit(s, (col * SQ_SIZE, new_row * SQ_SIZE + TOP_MARGIN))

                # Pawn initial two-square move (only from the starting position)
                if (piece[0] == 'w' and row == 6) or (piece[0] == 'b' and row == 1):
                    new_row = row + 2 * direction
                    if 0 <= new_row < 8 and gs.board[new_row][col] == "--":  # Check if the square is empty and within bounds
                        s.fill(p.Color('yellow'))  # Color for valid move (yellow)
                        screen.blit(s, (col * SQ_SIZE, new_row * SQ_SIZE + TOP_MARGIN))

                        
            if piece[1] == 'N':  # Knight
                # Knight move offsets (8 possible moves)
                knight_moves = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)]
                for move in knight_moves:
                    new_row = row + move[0]
                    new_col = col + move[1]
                    if 0 <= new_row < 8 and 0 <= new_col < 8:
                        if gs.board[new_row][new_col] != "--":  # If there's a piece
                            if gs.board[new_row][new_col][0] != piece[0]:  # If it's opposite color
                                s.fill(p.Color('red'))  # Color for the capture move (red)
                                screen.blit(s, (new_col * SQ_SIZE, new_row * SQ_SIZE + TOP_MARGIN))
                        else:  # If the square is empty, it's a valid move
                            s.fill(p.Color('yellow'))  # Color for valid move (yellow)
                            screen.blit(s, (new_col * SQ_SIZE, new_row * SQ_SIZE + TOP_MARGIN))

            if piece[1] == 'B':  # Bishop
                # Diagonal moves (four directions)
                for drow, dcol in [(-1, -1), (-1, 1), (1, -1), (1, 1)]:
                    r, c = row, col
                    while True:
                        r += drow
                        c += dcol
                        if 0 <= r < 8 and 0 <= c < 8:
                            if gs.board[r][c] != "--":  # If there's a piece
                                if gs.board[r][c][0] != piece[0]:  # If it's opposite color
                                    s.fill(p.Color('red'))  # Color for the capture move (red)
                                    screen.blit(s, (c * SQ_SIZE, r * SQ_SIZE + TOP_MARGIN))
                                break  # Stop at the first piece
                            s.fill(p.Color('yellow'))  # Color for valid move (yellow)
                            screen.blit(s, (c * SQ_SIZE, r * SQ_SIZE + TOP_MARGIN))
                        else:
                            break

            if piece[1] == 'Q':  # Queen
                for i in range(col + 1, 8):  # Right
                    if gs.board[row][i] != "--":
                        if gs.board[row][i][0] != piece[0]:
                            s.fill(p.Color('red'))  # Color for the capture move (red)
                            screen.blit(s, (i * SQ_SIZE, row * SQ_SIZE + TOP_MARGIN))
                        break
                    s.fill(p.Color('yellow'))
                    screen.blit(s, (i * SQ_SIZE, row * SQ_SIZE + TOP_MARGIN))

                for i in range(col - 1, -1, -1):  # Left
                    if gs.board[row][i] != "--":
                        if gs.board[row][i][0] != piece[0]:
                            s.fill(p.Color('red'))  # Color for the capture move (red)
                            screen.blit(s, (i * SQ_SIZE, row * SQ_SIZE + TOP_MARGIN))
                        break
                    s.fill(p.Color('yellow'))
                    screen.blit(s, (i * SQ_SIZE, row * SQ_SIZE + TOP_MARGIN))

                for i in range(row + 1, 8):  # Down
                    if gs.board[i][col] != "--":
                        if gs.board[i][col][0] != piece[0]:
                            s.fill(p.Color('red'))  # Color for the capture move (red)
                            screen.blit(s, (col * SQ_SIZE, i * SQ_SIZE + TOP_MARGIN))
                        break
                    s.fill(p.Color('yellow'))
                    screen.blit(s, (col * SQ_SIZE, i * SQ_SIZE + TOP_MARGIN))

                for i in range(row - 1, -1, -1):  # Up
                    if gs.board[i][col] != "--":
                        if gs.board[i][col][0] != piece[0]:
                            s.fill(p.Color('red'))  # Color for the capture move (red)
                            screen.blit(s, (col * SQ_SIZE, i * SQ_SIZE + TOP_MARGIN))
                        break
                    s.fill(p.Color('yellow'))
                    screen.blit(s, (col * SQ_SIZE, i * SQ_SIZE + TOP_MARGIN))

                # Diagonal moves (Bishop-like moves)
                for drow, dcol in [(-1, -1), (-1, 1), (1, -1), (1, 1)]:
                    r, c = row, col
                    while True:
                        r += drow
                        c += dcol
                        if 0 <= r < 8 and 0 <= c < 8:
                            if gs.board[r][c] != "--":  # If there's a piece
                                if gs.board[r][c][0] != piece[0]:  # If it's opposite color
                                    s.fill(p.Color('red'))  # Color for the capture move (red)
                                    screen.blit(s, (c * SQ_SIZE, r * SQ_SIZE + TOP_MARGIN))
                                break  # Stop at the first piece
                            s.fill(p.Color('yellow'))  # Color for valid move (yellow)
                            screen.blit(s, (c * SQ_SIZE, r * SQ_SIZE + TOP_MARGIN))
                        else:
                            break

            if piece[1] == 'K':  # King
                # King can move one square in any direction
                king_moves = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
                for move in king_moves:
                    new_row = row + move[0]
                    new_col = col + move[1]
                    if 0 <= new_row < 8 and 0 <= new_col < 8:
                        if gs.board[new_row][new_col] != "--":  # If there's a piece
                            if gs.board[new_row][new_col][0] != piece[0]:  # If it's opposite color
                                s.fill(p.Color('red'))  # Color for the capture move (red)
                                screen.blit(s, (new_col * SQ_SIZE, new_row * SQ_SIZE + TOP_MARGIN))
                        else:  # If the square is empty, it's a valid move
                            s.fill(p.Color('yellow'))  # Color for valid move (yellow)
                            screen.blit(s, (new_col * SQ_SIZE, new_row * SQ_SIZE + TOP_MARGIN))

def drawGameState(screen, gs, sqSelected):
    drawBoard(screen)
    highlightsquare(screen, gs, sqSelected)
    drawPieces(screen, gs.board)

def drawBoard(screen):
    colors = [p.Color("white"), p.Color("gray")]
    for r in range(DIMENSION):
        for c in range(DIMENSION):
            color = colors[((r + c) % 2)]
            p.draw.rect(screen, color, p.Rect(c * SQ_SIZE, TOP_MARGIN + r * SQ_SIZE, SQ_SIZE, SQ_SIZE))

def drawPieces(screen, board):
    for r in range(DIMENSION):
        for c in range(DIMENSION):
            piece = board[r][c]
            if piece != "--":
                screen.blit(IMAGES[piece], p.Rect(c * SQ_SIZE, TOP_MARGIN + r * SQ_SIZE, SQ_SIZE, SQ_SIZE))


def drawGameState(screen, gs, sqSelected):
    drawBoard(screen)
    highlightsquare(screen, gs, sqSelected)
    drawPieces(screen, gs.board)

def drawBoard(screen):
    colors = [p.Color("white"), p.Color("gray")]
    for r in range(DIMENSION):
        for c in range(DIMENSION):
            color = colors[((r + c) % 2)]
            p.draw.rect(screen, color, p.Rect(c * SQ_SIZE, TOP_MARGIN + r * SQ_SIZE, SQ_SIZE, SQ_SIZE))


def drawPieces(screen, board):
    for r in range(DIMENSION):
        for c in range (DIMENSION): 
            piece = board[r][c]
            if piece != "--":
                screen.blit(IMAGES[piece], p.Rect(c * SQ_SIZE, TOP_MARGIN + r * SQ_SIZE, SQ_SIZE, SQ_SIZE))            

def animateMove(move, screen, board, clock):
    colors = [p.Color("white"), p.Color("gray")]
    dr = move.endRow - move.startRow
    dc = move.endCol - move.startCol
    framesPerSquare = 10  # Adjust this for animation speed
    frameCount = (abs(dr) + abs(dc)) * framesPerSquare
    for frame in range(frameCount + 1):
        r, c = (move.startRow + dr * frame / frameCount, move.startCol + dc * frame / frameCount)
        drawBoard(screen)
        drawPieces(screen, board)
        
        # Draw an empty square on the starting position to clear the moving piece
        startSquareColor = colors[(move.startRow + move.startCol) % 2]
        startSquare = p.Rect(move.startCol * SQ_SIZE, move.startRow * SQ_SIZE + TOP_MARGIN, SQ_SIZE, SQ_SIZE)
        p.draw.rect(screen, startSquareColor, startSquare)
        
        # Draw the end square and captured piece if any
        endSquareColor = colors[(move.endRow + move.endCol) % 2]
        endSquare = p.Rect(move.endCol * SQ_SIZE, move.endRow * SQ_SIZE + TOP_MARGIN, SQ_SIZE, SQ_SIZE)
        p.draw.rect(screen, endSquareColor, endSquare)
        
        if move.pieceCaptured != "--":
            screen.blit(IMAGES[move.pieceCaptured], endSquare)
        
        # Draw the moving piece
        screen.blit(IMAGES[move.pieceMoved], p.Rect(c * SQ_SIZE, TOP_MARGIN + r * SQ_SIZE, SQ_SIZE, SQ_SIZE))
        p.display.flip()
        clock.tick(60)

    

if __name__ == "__main__":
    main()