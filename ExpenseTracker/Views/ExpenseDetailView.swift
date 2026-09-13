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
    @AppStorage("currencyCode") private var currencyCode = AppCurrency.usd.rawValue

    private var currency: AppCurrency {
        AppCurrency(rawValue: currencyCode) ?? .usd
    }

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
            VStack(spacing: 18) {
                Image(systemName: currentExpense.category.iconName)
                    .font(.title2)
                    .foregroundStyle(theme.primary)
                    .frame(width: 54, height: 54)
                    .background(theme.primary.opacity(0.14), in: Circle())

                Text(currentExpense.category.displayName.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(theme.primary)

                Text(currentExpense.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(theme.text)

                Text(currentExpense.amount.formattedCurrency(using: currency))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.text)

                Text(currentExpense.date, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 26)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(theme.text.opacity(0.08), lineWidth: 1)
            }

            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete Expense", systemImage: "trash")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
            }
            .buttonStyle(.bordered)
            .tint(theme.danger)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background.ignoresSafeArea())
        .navigationTitle("Expense Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(theme.surface, for: .navigationBar)
        .toolbarColorScheme(theme.isDark ? .dark : .light, for: .navigationBar)
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
                Haptics.light()
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
