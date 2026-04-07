//
//  HomeView.swift
//  Tally
//
//  Created by Mazen Tarek on 3/7/26.
//

import SwiftUI

struct HomeView: View {

    @StateObject private var homeViewModel = HomeViewModel()
    @State private var selectedTab: Int = 0
    @State private var showAddTransaction: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeDashboardView(viewModel: homeViewModel, selectedTab: $selectedTab)
                    .tag(0)
                BudgetView()
                    .tag(1)
                InsightsView()
                    .tag(2)
                ProfileView()
                    .tag(3)
            }

            customTabBar
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView {
                homeViewModel.loadData()
            }
        }
    }


    private var customTabBar: some View {
        ZStack {
            HStack(spacing: 0) {
                tabBarItem(icon: "house.fill", label: "Home", tag: 0)
                tabBarItem(icon: "chart.pie", label: "Budget", tag: 1)
                Spacer().frame(maxWidth: .infinity)
                tabBarItem(icon: "chart.bar", label: "Insights", tag: 2)
                tabBarItem(icon: "person", label: "Profile", tag: 3)
            }
            .padding(.horizontal, 8)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: -4)

            // FAB
            Button {
                showAddTransaction = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.primaryBlue)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.primaryBlue.opacity(0.4), radius: 12, x: 0, y: 6)
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .offset(y: -16)
        }
    }

    private func tabBarItem(icon: String, label: String, tag: Int) -> some View {
        Button {
            selectedTab = tag
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(selectedTab == tag ? Color.primaryBlue : Color.mutedText)
                Text(label)
                    .font(.manrope(.medium, size: 11))
                    .foregroundStyle(selectedTab == tag ? Color.primaryBlue : Color.mutedText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HomeView()
}
