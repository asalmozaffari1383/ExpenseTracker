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
    @AppStorage("currencyCode") private var currencyCode = AppCurrency.usd.rawValue

    private var currency: AppCurrency {
        AppCurrency(rawValue: currencyCode) ?? .usd
    }
    
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
            ScrollView {
                VStack(spacing: 18) {
                    Text("Track where your money goes.")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 0) {
                        themedField("Title", systemImage: "text.alignleft") {
                            TextField("e.g. Coffee", text: $title)
                                .foregroundStyle(theme.text)
                        }

                        Divider().overlay(theme.surfaceElevated)

                        themedField("Amount", systemImage: "dollarsign") {
                            TextField("0.00 \(currency.inputSuffix)", text: $amountString)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(theme.text)
                        }

                        Divider().overlay(theme.surfaceElevated)

                        themedField("Category", systemImage: selectedCategory.iconName) {
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(Category.allCases) { category in
                                    Text(category.displayName).tag(category)
                                }
                            }
                            .labelsHidden()
                            .foregroundStyle(theme.text)
                            .tint(theme.primary)
                        }

                        Divider().overlay(theme.surfaceElevated)

                        themedField("Date", systemImage: "calendar") {
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                                .foregroundStyle(theme.text)
                                .tint(theme.primary)
                        }
                    }
                    .background(theme.surface, in: RoundedRectangle(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(theme.text.opacity(0.08), lineWidth: 1)
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .background(theme.background)
            .tint(theme.primary)
            .navigationTitle(existingExpense == nil ? "New Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(theme.surface, for: .navigationBar)
            .toolbarColorScheme(theme.isDark ? .dark : .light, for: .navigationBar)
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
                        Haptics.light()
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private func themedField<Content: View>(
        _ title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(theme.primary)
                .frame(width: 22)

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.secondaryText)

            Spacer(minLength: 8)
            content()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
    }
}

#Preview {
    AddExpenseView { _ in }
}
