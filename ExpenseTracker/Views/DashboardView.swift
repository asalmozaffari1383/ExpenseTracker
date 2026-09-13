//
//  DashboardView.swift
//  ExpenseTracker
//

import SwiftUI

struct DashboardView: View {

    @Binding var expenses: [Expense]
    @Binding var incomes: [Income]
    @Binding var themeMode: ThemeMode

    let onSeeAllTapped: () -> Void
    let onAddExpenseTapped: () -> Void
    let onAddIncomeTapped: () -> Void

    @AppStorage("monthlyBudgetLimit") private var monthlyBudgetLimit: Double = 2_000.0

    private var theme: AppTheme {
        themeMode == .dark ? .dark : .light
    }

    private var totalIncome: Double {
        incomes.reduce(0) { $0 + $1.amount }
    }

    private var totalExpense: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    private var balance: Double {
        totalIncome - totalExpense
    }

    private var budgetRemaining: Double {
        monthlyBudgetLimit - totalExpense
    }

    private var budgetProgress: Double {
        guard monthlyBudgetLimit > 0 else { return 0 }
        return min(max(totalExpense / monthlyBudgetLimit, 0), 1)
    }

    private var dailyAverageSpend: Double? {
        guard totalExpense > 0 else { return nil }
        let dayOfMonth = Calendar.current.component(.day, from: Date())
        return totalExpense / Double(max(dayOfMonth, 1))
    }

    private var recentTransactions: [TransactionRowItem] {
        let transactions = expenses.map(TransactionRowItem.expense)
            + incomes.map(TransactionRowItem.income)

        return transactions
            .sorted { transactionDate($0) > transactionDate($1) }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header

                        FinancialSummaryCard(
                            balance: balance,
                            totalIncome: totalIncome,
                            totalExpense: totalExpense,
                            theme: theme
                        )

                        BudgetProgressCard(
                            monthlyBudget: monthlyBudgetLimit,
                            totalExpense: totalExpense,
                            budgetRemaining: budgetRemaining,
                            budgetProgress: budgetProgress,
                            dailyAverageSpend: dailyAverageSpend,
                            theme: theme
                        )

                        QuickActionButtons(
                            theme: theme,
                            onAddIncome: onAddIncomeTapped,
                            onAddExpense: onAddExpenseTapped
                        )

                        recentActivity
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(theme.isDark ? .dark : .light)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good to see you")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
                Text("Dashboard")
                    .font(.largeTitle.bold())
                    .foregroundStyle(theme.text)
            }

            Spacer()

            Button {
                Haptics.light()
                themeMode = themeMode == .dark ? .light : .dark
            } label: {
                Image(systemName: themeMode == .dark ? "sun.max.fill" : "moon.fill")
                    .font(.title3)
                    .foregroundStyle(theme.text)
                    .frame(width: 42, height: 42)
                    .background(theme.surface, in: Circle())
                    .overlay {
                        Circle().stroke(theme.surfaceElevated, lineWidth: 1)
                    }
            }
            .accessibilityLabel("Toggle color theme")
        }
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundStyle(theme.text)

                Spacer()

                Button(action: onSeeAllTapped) {
                    Label("See All", systemImage: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.primary)
                }
                .buttonStyle(.plain)
            }

            if recentTransactions.isEmpty {
                Text("No activity yet")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(theme.surface, in: RoundedRectangle(cornerRadius: 15))
            } else {
                ForEach(recentTransactions) { transaction in
                    TransactionRow(transaction: transaction, theme: theme)
                }
            }
        }
    }

    private func transactionDate(_ transaction: TransactionRowItem) -> Date {
        switch transaction {
        case .expense(let expense): return expense.date
        case .income(let income): return income.date
        }
    }
}

#Preview {
    MainTabView()
}
