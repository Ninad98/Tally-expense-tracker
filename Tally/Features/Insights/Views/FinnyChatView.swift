//
//  FinnyChatView.swift
//  Tally
//
//  Created by Ninad Mankar on 4/21/26.
//



import SwiftUI

struct FinnyChatView: View {

    @ObservedObject var viewModel: FinnyChatViewModel
    @Environment(\.dismiss) private var dismiss

    // Suggested quick questions shown at the top.
    private let suggestions = [
        "How is my budget looking?",
        "What % of my budget is used?",
        "How can I improve my spending?",
        "Which category am I overspending on?"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageBG.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Quick suggestion chips shown when chat is fresh.
                    if viewModel.messages.count <= 1 {
                        suggestionChips
                            .padding(.top, 12)
                            .padding(.horizontal, 16)
                    }

                    // Message list.
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    messageBubble(message)
                                        .id(message.id)
                                }

                                // Typing indicator while waiting for response.
                                if viewModel.isLoading {
                                    typingIndicator
                                        .id("typing")
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .onChange(of: viewModel.messages.count) { _, _ in
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                        .onChange(of: viewModel.isLoading) { _, _ in
                            withAnimation {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }

                    inputBar
                }
            }
            .navigationTitle("Finny - AI Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.primaryBlue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private var suggestionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        viewModel.inputText = suggestion
                        viewModel.sendMessage()
                    } label: {
                        Text(suggestion)
                            .font(.manrope(.medium, size: 13))
                            .foregroundStyle(Color.primaryBlue)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.primaryBlue.opacity(0.08))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.primaryBlue.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == "assistant" {
                // Finny avatar
                ZStack {
                    Circle()
                        .fill(Color.primaryBlue)
                        .frame(width: 32, height: 32)
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Text(message.content)
                    .font(.manrope(.regular, size: 15))
                    .foregroundStyle(Color.heading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )
                    .clipShape(
                        .rect(
                            topLeadingRadius: 4,
                            bottomLeadingRadius: 18,
                            bottomTrailingRadius: 18,
                            topTrailingRadius: 18
                        )
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                Spacer(minLength: 48)

            } else {
                Spacer(minLength: 48)

                Text(message.content)
                    .font(.manrope(.regular, size: 15))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.primaryBlue)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: 18,
                            bottomTrailingRadius: 4,
                            topTrailingRadius: 18
                        )
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == "user" ? .trailing : .leading)
    }


    private var typingIndicator: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 32, height: 32)
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.mutedText)
                        .frame(width: 7, height: 7)
                        .opacity(0.4)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

            Spacer(minLength: 48)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }


    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField(
                "",
                text: $viewModel.inputText,
                prompt: Text("Ask Finny anything...").foregroundStyle(Color.mutedText)
            )
            .font(.manrope(.regular, size: 15))
            .foregroundStyle(Color.heading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
            .onSubmit { viewModel.sendMessage() }
            .disabled(viewModel.isLoading)

            Button {
                viewModel.sendMessage()
            } label: {
                ZStack {
                    Circle()
                        .fill(viewModel.inputText.isEmpty ? Color.primaryBlue.opacity(0.3) : Color.primaryBlue)
                        .frame(width: 44, height: 44)
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.pageBG)
    }
}
