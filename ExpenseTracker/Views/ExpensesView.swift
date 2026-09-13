//
//  ExpensesView.swift
//  ExpenseTracker
//

import SwiftUI

struct ExpensesView: View {

    @Binding var expenses: [Expense]
    let theme: AppTheme

    @State private var showingAddExpense = false

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background
                    .ignoresSafeArea()

                if expenses.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(expenses) { expense in
                            NavigationLink {
                                ExpenseDetailView(
                                    expense: expense,
                                    theme: theme,
                                    onUpdate: updateExpense,
                                    onDelete: deleteExpense
                                )
                            } label: {
                                TransactionRow(
                                    transaction: .expense(expense),
                                    theme: theme
                                )
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteExpense(expense.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(theme.surface, for: .navigationBar)
            .toolbarColorScheme(theme.isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptics.light()
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add expense")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(theme: theme) { expense in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expenses.insert(expense, at: 0)
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: expenses.count)
        .preferredColorScheme(theme.isDark ? .dark : .light)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 42))
                .foregroundStyle(theme.primary)
                .padding(20)
                .background(theme.primary.opacity(0.12), in: Circle())
            Text("No expenses yet")
                .font(.title3.bold())
                .foregroundStyle(theme.text)
            Text("Start tracking your spending to see your financial picture here.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.secondaryText)
                .frame(maxWidth: 270)
            Button {
                showingAddExpense = true
            } label: {
                Label("Add Expense", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.primary)
        }
        .padding()
    }

    private func updateExpense(_ updatedExpense: Expense) {
        guard let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) else {
            return
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            expenses[index] = updatedExpense
        }
    }

    private func deleteExpense(_ id: UUID) {
        Haptics.light()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            expenses.removeAll { $0.id == id }
        }
    }
}
