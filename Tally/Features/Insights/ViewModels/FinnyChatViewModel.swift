//
//  FinnyChatViewModel.swift
//  Tally
//
//  Created by Ninad Mankar on 4/21/26.
//

import Combine
import SwiftUI

final class FinnyChatViewModel: ObservableObject {

    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false

    private let totalSpent: Double
    private let totalIncome: Double
    private let budgetGoal: Double
    private let budgetRemaining: Double
    private let period: String
    private let categoryBreakdowns: [CategoryInsight]

    private let apiKey = "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"

    init(
        totalSpent: Double,
        totalIncome: Double,
        budgetGoal: Double,
        budgetRemaining: Double,
        period: String,
        categoryBreakdowns: [CategoryInsight]
    ) {
        self.totalSpent = totalSpent
        self.totalIncome = totalIncome
        self.budgetGoal = budgetGoal
        self.budgetRemaining = budgetRemaining
        self.period = period
        self.categoryBreakdowns = categoryBreakdowns

        messages.append(ChatMessage(
            role: "assistant",
            content: "Hey! I'm Finny, your AI financial coach. I can see your \(period.lowercased()) spending data. Ask me anything about your budget!"
        ))
    }

    private var systemPrompt: String {
        var categoryText = ""
        for cat in categoryBreakdowns {
            categoryText += "\n  - \(cat.name): \(cat.amount.asCurrency()) (\(String(format: "%.0f", cat.percentage))% of spend)"
        }
        if categoryText.isEmpty { categoryText = "\n  - No spending data available" }

        return """
        You are Finny, a friendly and knowledgeable AI financial coach built into the Tally personal finance app.

        The user's current \(period.lowercased()) financial snapshot:
        - Total Spent: \(totalSpent.asCurrency())
        - Total Income: \(totalIncome.asCurrency())
        - Budget Goal: \(budgetGoal.asCurrency())
        - Budget Remaining: \(budgetRemaining.asCurrency())
        - Budget Used: \(budgetGoal > 0 ? String(format: "%.0f", (totalSpent / budgetGoal) * 100) + "%" : "No budget set")
        - Category Breakdown:\(categoryText)

        Answer questions about their finances in a friendly, concise, and actionable way.
        Keep responses to 2-4 sentences max. Give specific advice based on their actual data.
        Do not make up any financial figures not provided above.
        """
    }

    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isLoading else { return }

        let userMessage = ChatMessage(role: "user", content: trimmed)
        messages.append(userMessage)
        inputText = ""
        isLoading = true

        Task {
            do {
                let reply = try await callAnthropicAPI()
                await MainActor.run {
                    messages.append(ChatMessage(role: "assistant", content: reply))
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    messages.append(ChatMessage(
                        role: "assistant",
                        content: "Sorry, I ran into an issue. Please try again!"
                    ))
                    isLoading = false
                }
            }
        }
    }

    private func callAnthropicAPI() async throws -> String {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        // Build conversation history — drop the opening greeting, keep everything else.
        let conversationMessages = messages
            .dropFirst()
            .map { ["role": $0.role, "content": $0.content] }

        let body: [String: Any] = [
            "model": "claude-sonnet-4-5",
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": conversationMessages
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        // Log error response from API for easier debugging.
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("Anthropic API error \(httpResponse.statusCode): \(errorBody)")
            throw URLError(.badServerResponse)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let text = content.first?["text"] as? String
        else {
            throw URLError(.badServerResponse)
        }

        return text
    }
}
