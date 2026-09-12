//
//  ExpenseDetailView.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.
//

import SwiftUI

struct ExpenseDetailView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var currentExpense: Expense
    @State private var showingEditExpense = false
    @State private var showingDeleteConfirmation = false

    let theme: AppTheme
    let onUpdate: (Expense) -> Void
    let onDelete: (UUID) -> Void

    init(
        expense: Expense,
        theme: AppTheme = .dark,
        onUpdate: @escaping (Expense) -> Void = { _ in },
        onDelete: @escaping (UUID) -> Void = { _ in }
    ) {
        _currentExpense = State(initialValue: expense)
        self.theme = theme
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(currentExpense.category.displayName)
                .font(.headline)
                .foregroundStyle(theme.primary)
            
            Text(currentExpense.title)
                .font(.largeTitle.bold())
                .foregroundStyle(theme.text)
            
            Text("$\(currentExpense.amount, specifier: "%.2f")")
                .font(.title)
                .foregroundStyle(theme.text)
            
            Text(currentExpense.date, style: .date)
                .foregroundStyle(theme.secondaryText)

            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete Expense", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(theme.danger)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background.ignoresSafeArea())
        .navigationTitle("Expense Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditExpense = true
                }
                .foregroundStyle(theme.primary)
            }
        }
        .sheet(isPresented: $showingEditExpense) {
            AddExpenseView(expense: currentExpense, theme: theme) { updatedExpense in
                currentExpense = updatedExpense
                onUpdate(updatedExpense)
            }
        }
        .alert("Delete Expense?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete(currentExpense.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This expense will be permanently removed.")
        }
    }
}

#Preview {
    ExpenseDetailView(
        expense: Expense(
            title: "Coffee",
            amount: 5,
            category: .food,
            date: Date()
        )
    )
}
