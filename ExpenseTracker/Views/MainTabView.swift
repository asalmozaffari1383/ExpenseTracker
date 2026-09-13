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
    @AppStorage("themeMode") private var themeModeRawValue = ThemeMode.dark.rawValue
    @State private var showingAddExpense = false
    @State private var showingAddIncome = false
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

    private var themeMode: ThemeMode {
        ThemeMode(rawValue: themeModeRawValue) ?? .dark
    }

    private var themeModeBinding: Binding<ThemeMode> {
        Binding(
            get: { ThemeMode(rawValue: themeModeRawValue) ?? .dark },
            set: { themeModeRawValue = $0.rawValue }
        )
    }

    private var theme: AppTheme {
        themeMode == .dark ? .dark : .light
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(
                expenses: $expenses,
                incomes: $incomes,
                themeMode: themeModeBinding,
                onSeeAllTapped: { selectedTab = .expenses },
                onAddExpenseTapped: { showingAddExpense = true },
                onAddIncomeTapped: { showingAddIncome = true }
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

            AnalyticsView(expenses: expenses, theme: theme)
                .tag(Tab.analytics)
                .tabItem {
                    Label("Analytics", systemImage: "chart.pie.fill")
                }

            SettingsView(
                themeMode: themeModeBinding,
                theme: theme,
                transactionCount: expenses.count + incomes.count,
                onDeleteAllData: deleteAllData
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
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(theme: theme) { expense in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expenses.insert(expense, at: 0)
                }
            }
        }
        .sheet(isPresented: $showingAddIncome) {
            AddIncomeView(theme: theme) { income in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    incomes.insert(income, at: 0)
                }
            }
        }
    }

    private func deleteAllData() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            expenses.removeAll()
            incomes.removeAll()
        }
        Haptics.light()
    }
}

#Preview {
    MainTabView()
}
