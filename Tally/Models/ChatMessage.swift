//
//  ChatMessage.swift
//  Tally
//
//  Created by Ninad Mankar on 4/21/26.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: String // "user" or "assistant"
    let content: String
    let timestamp: Date = Date()
}
