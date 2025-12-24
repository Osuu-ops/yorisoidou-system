# TicTacToe - Console Game
# S-phase confirmed artifact

def print_board(board):
    for i, row in enumerate(board):
        print(" | ".join(row))
        if i < 2:
            print("-" * 9)

def check_winner(board, player):
    # Rows
    for row in board:
        if all(cell == player for cell in row):
            return True

    # Columns
    for col in range(3):
        if all(board[row][col] == player for row in range(3)):
            return True

    # Diagonals
    if all(board[i][i] == player for i in range(3)):
        return True
    if all(board[i][2 - i] == player for i in range(3)):
        return True

    return False

def is_draw(board):
    return all(cell != " " for row in board for cell in row)

def main():
    board = [[" " for _ in range(3)] for _ in range(3)]
    players = ["X", "O"]
    turn = 0

    while True:
        print_board(board)
        current_player = players[turn % 2]

        try:
            row = int(input(f"Player {current_player} - Row (1-3): ")) - 1
            col = int(input(f"Player {current_player} - Col (1-3): ")) - 1
        except ValueError:
            print("Invalid input. Please enter numbers between 1 and 3.")
            continue

        if row not in range(3) or col not in range(3):
            print("Invalid position. Choose values between 1 and 3.")
            continue

        if board[row][col] != " ":
            print("Cell already occupied. Choose another.")
            continue

        board[row][col] = current_player

        if check_winner(board, current_player):
            print_board(board)
            print(f"Player {current_player} wins!")
            break

        if is_draw(board):
            print_board(board)
            print("Draw.")
            break

        turn += 1

if __name__ == "__main__":
    main()
