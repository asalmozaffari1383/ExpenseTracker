//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.
//

import SwiftUI

struct AddExpenseView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let existingExpense: Expense?
    let theme: AppTheme
    let onSave: (Expense) -> Void
    
    @State private var title: String
    @State private var amountString: String
    @State private var selectedCategory: Category
    @State private var date: Date

    init(
        expense: Expense? = nil,
        theme: AppTheme = .dark,
        onSave: @escaping (Expense) -> Void
    ) {
        self.existingExpense = expense
        self.theme = theme
        self.onSave = onSave
        _title = State(initialValue: expense?.title ?? "")
        _amountString = State(
            initialValue: expense.map { String(format: "%.2f", $0.amount) } ?? ""
        )
        _selectedCategory = State(initialValue: expense?.category ?? .food)
        _date = State(initialValue: expense?.date ?? Date())
    }
    
    private var isValid: Bool {
        guard !title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty,
              let amount = Double(amountString),
              amount > 0
        else {
            return false
        }
        
        return true
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                    
                    TextField(
                        "Title (e.g. Coffee)",
                        text: $title
                    )
                    .foregroundStyle(theme.text)
                    
                    TextField(
                        "Amount ($)",
                        text: $amountString
                    )
                    .keyboardType(.decimalPad)
                    .foregroundStyle(theme.text)
                    
                    Picker(
                        "Category",
                        selection: $selectedCategory
                    ) {
                        ForEach(Category.allCases) { category in
                            Label(
                                category.displayName,
                                systemImage: category.iconName
                            )
                            .tag(category)
                        }
                    }
                    .foregroundStyle(theme.text)
                    
                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: .date
                    )
                    .foregroundStyle(theme.text)
                }
                .listRowBackground(theme.surface)
            }
            .scrollContentBackground(.hidden)
            .background(theme.background)
            .tint(theme.primary)
            .navigationTitle(existingExpense == nil ? "New Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                // Cancel
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                // Save
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        
                        guard let amount = Double(amountString) else {
                            return
                        }
                        
                        let savedExpense = Expense(
                            id: existingExpense?.id ?? UUID(),
                            title: title.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ),
                            amount: amount,
                            category: selectedCategory,
                            date: date
                        )
                        
                        onSave(savedExpense)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

#Preview {
    AddExpenseView { _ in }
}
