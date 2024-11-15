from pyswip import Prolog

class GameState():
    def __init__(self):
        self.board = [
            ["bR", "bN", "bB", "bQ", "bK", "bB", "bN", "bR"],
            ["bp", "bp", "bp", "bp", "bp", "bp", "bp", "bp"],
            ["--", "--", "--", "--", "--", "--", "--", "--"],
            ["--", "--", "--", "--", "--", "--", "--", "--"],
            ["--", "--", "--", "--", "--", "--", "--", "--"],
            ["--", "--", "--", "--", "--", "--", "--", "--"],
            ["wp", "wp", "wp", "wp", "wp", "wp", "wp", "wp"],
            ["wR", "wN", "wB", "wQ", "wK", "wB", "wN", "wR"]
        ]
        self.whiteToMove = True
        self.moveLog = []
    
        # Initialize Prolog engine
        self.prolog = Prolog()
        self.prolog.consult("piece_rule.pl")  # Load Prolog rules

    def makeMove(self, move):
        # Extract piece and move information
        piece = move.pieceMoved
        startRow, startCol = move.startRow, move.startCol
        endRow, endCol = move.endRow, move.endCol

        first = self.board[startRow][startCol]
        second = self.board[endRow][endCol]

        if first[0] == second[0]:
            return "same_color"

        print("piece: " + piece)
        print("startRow: " + str(startRow) + " startCol: " + str(startCol))
        print("endRow: " + str(endRow) + " endCol: " + str(endCol))
        
        if self.myMove(piece):
            valid_move = list(self.prolog.query(f"move_valid({piece}, {startRow}, {startCol}, {endRow}, {endCol})"))
            print("is it valid: " + str(valid_move))
            if valid_move:
                # If move is valid, update the board
                self.board[startRow][startCol] = "--"
                self.board[endRow][endCol] = piece
                self.prolog.retract(f"piece({piece}, {startRow}, {startCol})")
                self.prolog.assertz(f"piece({piece}, {endRow}, {endCol})")
                self.moveLog.append(move)
                self.whiteToMove = not self.whiteToMove
                return True
            else:
                return False
        else:
            return False
        
    def myMove(self, piece):
        piece = piece[0]
        if self.whiteToMove == True and piece == "w":
            return True
        elif self.whiteToMove == False and piece == "b":
            return True
        else:
            return False

class Move():
    ranksToRows = {"1":7, "2":6, "3":5, "4": 4 , "5":3, "6":2, "7": 1, "8":0}
    rowsToRanks = {v:k for k, v in ranksToRows.items()}

    filesToCols = {"a":0, "b": 1, "c": 2, "d": 3, "e": 4, "f": 5, "g": 6, "h": 7}
    colsToFiles = {v:k for k, v in filesToCols.items()}

    def __init__(self, startSq, endSq, board):
        self.startRow = startSq[0]
        self.startCol = startSq[1]
        self.endRow = endSq[0]
        self.endCol = endSq[1]
        self.pieceMoved = board[self.startRow][self.startCol]
        self.pieceCaptured = board[self.endRow][self.endCol]
    
    def getChessNotation(self):
        return self.getRankFile(self.startRow, self.startCol) + self.getRankFile(self.endRow,self.endCol)
    
    def getRankFile(self,r,c):
        return self.colsToFiles[c] + self.rowsToRanks[r]
