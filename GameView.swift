//
//  GameView.swift
//  TicTacToe
//
//  Created by Kostya Syzdykov on 05.09.2022.
//

import SwiftUI

/*
 Field:
 0 1 2
 3 4 5
 6 7 8
 */

struct GameView: View {
    
    // It makes our 3 columns to be flexible
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    // What cells we should take to win
    let winPatterns: Set <Set <Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
    
    // Array of the length 9, with auto-completing with nil (0)
    @State private var moves: [Move?] = Array(repeating: nil, count: 9)
    @State private var isGameboardDisabled = false
    // This makes messages with a button 'Restart the game'
    @State private var alertItem: AlertItem?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Just space to make all pretty
                Spacer()
                // This makes a grid
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(0..<9) { i in
                        // This assigns for all of the 9 squares this mechanics
                        ZStack {
                            // Our field consists of 9 80x80 blue squares
                            Rectangle()
                                .foregroundColor(.blue).opacity(0.5)
                                .frame(width: geometry.size.width / 3 - 15,
                                       height: geometry.size.width / 3 - 15)
                            Image(systemName: moves[i]?.indicator ?? "")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            // If player taps on cell
                            // Check if it is occupied
                            if (isSquareOccupied(in: moves, forIndex: i)) { return }
                            moves[i] = Move(player: .human, boardIndex: i)
                            
                            // Check if player's move gived him a win
                            if checkWinCondition(for: .human, in: moves) {
                                alertItem = AlertContext.humanWins
                                return
                            }
                            
                            // After that check for draw
                            if checkForDraw(in: moves) {
                                alertItem = AlertContext.draw
                                return
                            }
                            
                            // Than dissable the board, so the player can't takes another cell while we will be in delay
                            isGameboardDisabled = true
                            
                            // Delay, so the player will think that he is fighting with a real person (if the AI will answer very quickly, it will be kind of weird)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                // Get the computer move using the function
                                let computerPosition = determineComputerMovePosition(in: moves)
                                moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
                                
                                // Turn on board
                                isGameboardDisabled = false
                                
                                // Check for stop-game conditions
                                if checkWinCondition(for: .computer, in: moves) {
                                    alertItem = AlertContext.computerWins
                                    return
                                }
                                
                                if checkForDraw(in: moves) {
                                    alertItem = AlertContext.draw
                                    return
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            // Disable board
            .disabled(isGameboardDisabled)
            .padding()
            // This will announce our allert, if with need it, with a button, which resets the game
            .alert(item: $alertItem, content: { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle, action: { resetGame() }))
            })
        }
    }
    
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        // Check for cell is not equal to nil
        return moves.contains(where: { $0?.boardIndex == index })
    }
    
    func computerTriesToWin(in moves: [Move?]) -> Int {
        // Iterate over all win patterns, if we have only 2 cells of pattern occpied by us, and the other one is empty
        let computerMoves = moves.compactMap { $0 }.filter { $0.player == .computer }
        let computerPositions = Set(computerMoves.map { $0.boardIndex })
        
        for pattern in winPatterns {
            // subtract from pattern all positions that are occupied by us
            let winPositions = pattern.subtracting(computerPositions)
            
            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable { return winPositions.first! }
            }
        }
        
        return -1
    }
    
    func computerTriesToBlock(in moves: [Move?]) -> Int {
        // The same logic as a win strategy, but here we try to block the last cell
        let humanMoves = moves.compactMap { $0 }.filter { $0.player == .human }
        let humanPositions = Set(humanMoves.map { $0.boardIndex })
        
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(humanPositions)
            
            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable { return winPositions.first! }
            }
        }
        
        return -1
    }
    
    func computerTriesToTakeMiddle(in moves: [Move?]) -> Int {
        // Just check
        let middle = 4
        if !isSquareOccupied(in: moves, forIndex: middle) {
            return middle
        }
        return -1
    }
    
    func computerTriesToUseRandom(in moves: [Move?]) -> Int {
        // Use a simple random to choose the move
        var movePosition = Int.random(in: 0..<9)
        
        while isSquareOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        
        return movePosition
    }
    
    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        // Checks for win cell
        var winPosition = computerTriesToWin(in: moves)
        if winPosition != -1 {
            return winPosition
        }

        // Checks for thread
        winPosition = computerTriesToBlock(in: moves)
        if winPosition != -1 {
            return winPosition
        }
        
        // Checks for middle cell
        winPosition = computerTriesToTakeMiddle(in: moves)
        if winPosition != -1 {
            return winPosition
        }
        
        // We made all we could
        return computerTriesToUseRandom(in: moves)
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        // Check through all win patterns for exact player
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }
        let playerPositions = Set(playerMoves.map { $0.boardIndex })
        
        for pattern in winPatterns where pattern.isSubset(of: playerPositions) {
            return true
        }
        
        return false
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        // We can't move if there isn't any free cell
        return moves.compactMap { $0 }.count == 9
    }
    
    func resetGame() {
        // Just clear the array
        moves = Array(repeating: nil, count: 9)
    }
}

// Player can be either human or computer
enum Player {
    case human, computer
}

// Structure that has its index on board and indicator of which player it is occupied
struct Move {
    let player: Player
    let boardIndex: Int
    
    var indicator: String {
        return player == .human ? "xmark" : "circle"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
