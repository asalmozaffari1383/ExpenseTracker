//
//  HomeView.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.
//

import SwiftUI

struct HomeView: View {
    
    @State private var themeMode: ThemeMode = .dark
    @State private var showingAddExpense = false
    @State private var showingAddIncome = false
    @State private var monthlyBudget = 2_000.0
    
    @State private var expenses: [Expense] = [
        Expense(
            title: "Coffee",
            amount: 5,
            category: .food,
            date: Date()
        ),
        Expense(
            title: "Pizza",
            amount: 18.50,
            category: .food,
            date: Date()
        ),
        Expense(
            title: "Taxi",
            amount: 12,
            category: .transport,
            date: Date()
        )
    ]

    @State private var incomes: [Income] = [
        Income(
            title: "Monthly salary",
            amount: 2_500,
            date: Date(),
            sourceCategory: .salary
        )
    ]

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
        monthlyBudget - totalExpense
    }

    private var budgetProgress: Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(max(totalExpense / monthlyBudget, 0), 1)
    }
    
    private var theme: AppTheme {
        switch themeMode {
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    
                    // MARK: - Header
                    
                    HStack {
                        Text("Overview")
                            .font(.largeTitle.bold())
                            .foregroundStyle(theme.text)
                        
                        Spacer()
                        
                        // Theme Button
                        Button {
                            themeMode = themeMode == .dark ? .light : .dark
                        } label: {
                            Image(
                                systemName: themeMode == .dark
                                ? "sun.max.fill"
                                : "moon.fill"
                            )
                            .font(.title3)
                            .foregroundStyle(theme.text)
                        }
                        .accessibilityLabel("Toggle color theme")
                        
                        // Add Expense Button
                        Button {
                            showingAddExpense = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.blue)
                        }
                        .padding(.leading, 8)

                        Button {
                            showingAddIncome = true
                        } label: {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.title2)
                                .foregroundStyle(theme.success)
                        }
                        .padding(.leading, 8)
                        .accessibilityLabel("Add income")
                    }

                    summaryCard

                    HStack {
                        Text("Recent Expenses")
                            .font(.headline)
                            .foregroundStyle(theme.text)
                        Spacer()
                    }
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(expenses) { expense in
                                NavigationLink {
                                    ExpenseDetailView(
                                        expense: expense,
                                        theme: theme,
                                        onUpdate: updateExpense,
                                        onDelete: deleteExpense
                                    )
                                } label: {
                                    ExpenseRow(
                                        expense: expense,
                                        theme: theme
                                    )
                                }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteExpense(expense)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(theme: theme) { newExpense in
                expenses.insert(newExpense, at: 0)
            }
        }
        .sheet(isPresented: $showingAddIncome) {
            AddIncomeView(theme: theme) { newIncome in
                incomes.insert(newIncome, at: 0)
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Balance")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)

                    Text(balance, format: .currency(code: "USD"))
                        .font(.title.bold())
                        .foregroundStyle(balance >= 0 ? theme.success : theme.danger)
                }

                Spacer()

                Image(systemName: balance >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                    .font(.title2)
                    .foregroundStyle(balance >= 0 ? theme.success : theme.danger)
                    .padding(12)
                    .background(
                        (balance >= 0 ? theme.success : theme.danger).opacity(0.14),
                        in: Circle()
                    )
            }

            HStack(spacing: 12) {
                summaryMetric(title: "Income", value: totalIncome, color: theme.success)
                summaryMetric(title: "Expenses", value: totalExpense, color: theme.danger)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Monthly Budget")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.text)
                    Spacer()
                    Text("\(budgetProgress * 100, specifier: "%.0f")%")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.primary)
                }

                ProgressView(value: budgetProgress)
                    .tint(theme.primary)

                HStack {
                    Text("\(budgetRemaining, format: .currency(code: "USD")) remaining")
                    Spacer()
                    Text("of \(monthlyBudget, format: .currency(code: "USD"))")
                }
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
            }
        }
        .padding(18)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 20))
    }

    private func summaryMetric(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
            Text(value, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(theme.surfaceElevated, in: RoundedRectangle(cornerRadius: 12))
    }

    private func updateExpense(_ updatedExpense: Expense) {
        guard let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) else {
            return
        }

        expenses[index] = updatedExpense
    }

    private func deleteExpense(_ expense: Expense) {
        deleteExpense(expense.id)
    }

    private func deleteExpense(_ id: UUID) {
        expenses.removeAll { $0.id == id }
    }
}

#Preview {
    HomeView()
}
