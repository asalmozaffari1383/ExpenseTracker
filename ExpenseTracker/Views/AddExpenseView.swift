//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.
//

import SwiftUI

struct AddExpenseView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var onSave: (Expense) -> Void
    
    @State private var title: String = ""
    @State private var amountString: String = ""
    @State private var selectedCategory: Category = .food
    @State private var date: Date = Date()
    
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
                    
                    TextField(
                        "Amount ($)",
                        text: $amountString
                    )
                    .keyboardType(.decimalPad)
                    
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
                    
                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: .date
                    )
                }
            }
            .navigationTitle("New Expense")
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
                        
                        let newExpense = Expense(
                            title: title.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ),
                            amount: amount,
                            category: selectedCategory,
                            date: date
                        )
                        
                        onSave(newExpense)
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
