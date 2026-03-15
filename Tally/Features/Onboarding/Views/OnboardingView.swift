//
//  OnboardingView.swift
//  Tally
//
//  Created by Mazen Tarek on 3/14/26.
//

import SwiftUI

struct OnboardingPage {
    let image: String
    let title: String
    let body: String
}

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage: Int = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "Onboarding-1",
            title: "Master Your Money",
            body: "Track expenses, set budgets, and get\nAI-powered insights all in one place."
        ),
        OnboardingPage(
            image: "Onboarding-2",
            title: "Smart AI Insights",
            body: "Get personalized advice and answers to\nyour financial questions from our AI coach."
        ),
        OnboardingPage(
            image: "Onboarding-3",
            title: "Connect Your Bank",
            body: "No manual entry needed — your\ntransactions update instantly."
        )
    ]

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                pageContent(page: page, index: index)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(.white)
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func pageContent(page: OnboardingPage, index: Int) -> some View {
        let isLastPage = index == pages.count - 1

        VStack(spacing: 0) {
            Spacer()

            Image(page.image)
                .resizable()
                .scaledToFit()
                .frame(width: 312, height: 312)

            Spacer()

            VStack(spacing: 0) {
                Text(page.title)
                    .font(.urbanist(.extraBold, size: 36))
                    .foregroundStyle(Color.headingOnboarding)
                    .tracking(-0.9)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)

                Text(page.body)
                    .font(.manrope(.medium, size: 18))
                    .foregroundStyle(Color.bodyOnboarding)
                    .multilineTextAlignment(.center)
                    .lineSpacing(11.25)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
                    .frame(height: 40)

                progressDots(activeIndex: index)
                    .padding(.bottom, 40)

                actionButton(isLastPage: isLastPage)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
            .padding(.top, 32)
        }
    }

    private func progressDots(activeIndex: Int) -> some View {
        HStack(spacing: 12) {
            ForEach(0..<pages.count, id: \.self) { dotIndex in
                if dotIndex == activeIndex {
                    Capsule()
                        .fill(Color.primaryBlue)
                        .frame(width: 32, height: 10)
                } else {
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.2))
                        .frame(width: 10, height: 10)
                }
            }
        }
    }

    private func actionButton(isLastPage: Bool) -> some View {
        Button {
            if isLastPage {
                onComplete()
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage += 1
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(isLastPage ? "Get Started" : "Next")
                    .font(.urbanist(.bold, size: 18))

                if isLastPage {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: 320)
            .frame(height: 60)
            .background(Color.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(
                color: Color.primaryBlue.opacity(0.25),
                radius: 15, x: 0, y: 10
            )
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
