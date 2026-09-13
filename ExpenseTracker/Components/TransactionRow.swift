//
//  TransactionRow.swift
//  ExpenseTracker
//

import SwiftUI

enum TransactionRowItem: Identifiable {
    case expense(Expense)
    case income(Income)

    var id: UUID {
        switch self {
        case .expense(let expense): return expense.id
        case .income(let income): return income.id
        }
    }
}

struct TransactionRow: View {

    let transaction: TransactionRowItem
    let theme: AppTheme

    private var title: String {
        switch transaction {
        case .expense(let expense): return expense.title
        case .income(let income): return income.title
        }
    }

    private var subtitle: String {
        switch transaction {
        case .expense(let expense): return expense.category.displayName
        case .income(let income): return income.sourceCategory.displayName
        }
    }

    private var date: Date {
        switch transaction {
        case .expense(let expense): return expense.date
        case .income(let income): return income.date
        }
    }

    private var amount: Double {
        switch transaction {
        case .expense(let expense): return expense.amount
        case .income(let income): return income.amount
        }
    }

    private var isIncome: Bool {
        if case .income = transaction { return true }
        return false
    }

    private var accentColor: Color {
        isIncome ? theme.success : theme.danger
    }

    private var iconName: String {
        switch transaction {
        case .expense(let expense): return expense.category.iconName
        case .income(let income): return income.sourceCategory.iconName
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(accentColor)
                .frame(width: 38, height: 38)
                .background(accentColor.opacity(0.14), in: RoundedRectangle(cornerRadius: 11))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.text)
                HStack(spacing: 5) {
                    Text(subtitle)
                    Text("•")
                    Text(date, style: .date)
                }
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
            }

            Spacer()

            Text("\(isIncome ? "+" : "-")\(amount, format: .currency(code: "USD"))")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(accentColor)
        }
        .padding(12)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 15))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(theme.surfaceElevated, lineWidth: 1)
        }
    }
}
