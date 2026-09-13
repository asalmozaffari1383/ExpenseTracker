//
//  AddIncomeView.swift
//  ExpenseTracker
//

import SwiftUI

struct AddIncomeView: View {

    @Environment(\.dismiss) private var dismiss

    let theme: AppTheme
    let onSave: (Income) -> Void
    @AppStorage("currencyCode") private var currencyCode = AppCurrency.usd.rawValue

    private var currency: AppCurrency {
        AppCurrency(rawValue: currencyCode) ?? .usd
    }

    @State private var title = ""
    @State private var amountString = ""
    @State private var selectedCategory: IncomeCategory = .salary
    @State private var date = Date()

    init(theme: AppTheme = .dark, onSave: @escaping (Income) -> Void) {
        self.theme = theme
        self.onSave = onSave
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && Double(amountString).map { $0 > 0 } == true
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Text("Add money coming into your accounts.")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 0) {
                        themedField("Title", systemImage: "text.alignleft") {
                            TextField("e.g. Monthly salary", text: $title)
                                .foregroundStyle(theme.text)
                        }

                        Divider().overlay(theme.surfaceElevated)

                        themedField("Amount", systemImage: "dollarsign") {
                            TextField("0.00 \(currency.inputSuffix)", text: $amountString)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(theme.text)
                        }

                        Divider().overlay(theme.surfaceElevated)

                        themedField("Source", systemImage: selectedCategory.iconName) {
                            Picker("Source", selection: $selectedCategory) {
                                ForEach(IncomeCategory.allCases) { category in
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
            .navigationTitle("New Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(theme.surface, for: .navigationBar)
            .toolbarColorScheme(theme.isDark ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let amount = Double(amountString), isValid else {
                            return
                        }

                        let newIncome = Income(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            amount: amount,
                            date: date,
                            sourceCategory: selectedCategory
                        )

                        onSave(newIncome)
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
                .foregroundStyle(theme.success)
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
    AddIncomeView { _ in }
}
