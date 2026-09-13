//
//  MainTabView.swift
//  ExpenseTracker
//

import SwiftUI

struct MainTabView: View {

    private enum Tab: Hashable {
        case dashboard
        case expenses
        case analytics
        case settings
    }

    @State private var selectedTab: Tab = .dashboard
    @State private var themeMode: ThemeMode = .dark
    @State private var monthlyBudget = 2_000.0
    @State private var expenses: [Expense] = [
        Expense(title: "Coffee", amount: 5, category: .food, date: Date()),
        Expense(title: "Pizza", amount: 18.50, category: .food, date: Date()),
        Expense(title: "Taxi", amount: 12, category: .transport, date: Date())
    ]
    @State private var incomes: [Income] = [
        Income(
            title: "Monthly salary",
            amount: 2_500,
            date: Date(),
            sourceCategory: .salary
        )
    ]

    private var theme: AppTheme {
        themeMode == .dark ? .dark : .light
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(
                expenses: $expenses,
                incomes: $incomes,
                monthlyBudget: $monthlyBudget,
                themeMode: $themeMode,
                onSeeAllTapped: { selectedTab = .expenses }
            )
            .tag(Tab.dashboard)
            .tabItem {
                Label("Dashboard", systemImage: "square.grid.2x2.fill")
            }

            ExpensesView(expenses: $expenses, theme: theme)
                .tag(Tab.expenses)
                .tabItem {
                    Label("Expenses", systemImage: "creditcard.fill")
                }

            AnalyticsPlaceholderView(theme: theme)
                .tag(Tab.analytics)
                .tabItem {
                    Label("Analytics", systemImage: "chart.pie.fill")
                }

            SettingsView(
                themeMode: $themeMode,
                monthlyBudget: $monthlyBudget,
                theme: theme
            )
            .tag(Tab.settings)
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(theme.primary)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(theme.surface, for: .tabBar)
        .toolbarColorScheme(themeMode == .dark ? .dark : .light, for: .tabBar)
        .preferredColorScheme(theme.isDark ? .dark : .light)
    }
}

#Preview {
    MainTabView()
}
