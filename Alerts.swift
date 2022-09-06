//
//  Alerts.swift
//  TicTacToe
//
//  Created by Kostya Syzdykov on 05.09.2022.
//

import SwiftUI

// Button characteristics
struct AlertItem: Identifiable {
    let id = UUID()
    var title: Text
    var message: Text
    var buttonTitle: Text
}

// We have 3 patterns of what message we say in the message
struct AlertContext {
    static let humanWins = AlertItem(title: Text("YOU WIN!"),
                                     message: Text("Congrats! You've beaten the robot"),
                                     buttonTitle: Text("Hell yeah"))
    
    static let computerWins = AlertItem(title: Text("LOSER!"),
                                        message: Text("You should think about training your brain"),
                                        buttonTitle: Text("Hell no"))
    
    static let draw = AlertItem(title: Text("DRAW"),
                                message: Text("Bruh moment"),
                                buttonTitle: Text("Hell bruh"))
}
