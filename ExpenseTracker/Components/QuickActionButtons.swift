//
//  QuickActionButtons.swift
//  ExpenseTracker
//

import SwiftUI

struct QuickActionButtons: View {

    let theme: AppTheme
    let onAddIncome: () -> Void
    let onAddExpense: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            actionButton(
                title: "Add Income",
                icon: "arrow.down.left",
                color: theme.success,
                action: onAddIncome
            )
            actionButton(
                title: "Add Expense",
                icon: "arrow.up.right",
                color: theme.primary,
                action: onAddExpense
            )
        }
    }

    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(theme.surface, in: RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.45), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
    }
}
