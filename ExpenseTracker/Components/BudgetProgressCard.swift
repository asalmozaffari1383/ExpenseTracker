//
//  BudgetProgressCard.swift
//  ExpenseTracker
//

import SwiftUI

struct BudgetProgressCard: View {

    let monthlyBudget: Double
    let totalExpense: Double
    let budgetRemaining: Double
    let budgetProgress: Double
    let dailyAverageSpend: Double?
    let theme: AppTheme
    @AppStorage("currencyCode") private var currencyCode = AppCurrency.usd.rawValue

    private var currency: AppCurrency {
        AppCurrency(rawValue: currencyCode) ?? .usd
    }

    private var healthTitle: String {
        if monthlyBudget <= 0 { return "Set Budget" }
        switch budgetProgress {
        case 1...: return "Over Budget"
        case 0.8...: return "Warning: \(String(format: "%.0f", budgetProgress * 100))% Used"
        default: return "On Track"
        }
    }

    private var healthColor: Color {
        if monthlyBudget <= 0 { return theme.warning }
        switch budgetProgress {
        case 1...: return theme.danger
        case 0.8...: return theme.warning
        default: return theme.success
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly Budget")
                        .font(.headline)
                        .foregroundStyle(theme.text)
                    Text("\(totalExpense.formattedCurrency(using: currency)) spent of \(monthlyBudget.formattedCurrency(using: currency))")
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                }

                Spacer()

                Text(healthTitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(healthColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(healthColor.opacity(0.14), in: Capsule())
            }

            // مهار پروگرس بین 0 تا 1 برای جلوگیری از باگ‌های رندر SwiftUI
            ProgressView(value: min(max(budgetProgress, 0.0), 1.0))
                .tint(healthColor)
                .scaleEffect(y: 1.4, anchor: .center)

            HStack {
                Label(
                    budgetRemaining >= 0 ? "Remaining" : "Over budget",
                    systemImage: budgetRemaining >= 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
                )
                .foregroundStyle(budgetRemaining >= 0 ? theme.success : theme.danger)

                Spacer()

                Text(abs(budgetRemaining).formattedCurrency(using: currency))
                    .foregroundStyle(theme.text)
            }
            .font(.caption.weight(.medium))

            if let dailyAverageSpend {
                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                    Text("Daily average")
                    Spacer()
                    Text(dailyAverageSpend.formattedCurrency(using: currency))
                        .foregroundStyle(theme.text)
                }
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.surface)
                .overlay {
                    LinearGradient(
                        colors: [theme.primary.opacity(0.10), theme.surface.opacity(0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(theme.text.opacity(0.08), lineWidth: 1)
        }
    }
}

#Preview {
    BudgetProgressCard(
        monthlyBudget: 2_000,
        totalExpense: 680,
        budgetRemaining: 1_320,
        budgetProgress: 0.34,
        dailyAverageSpend: 22.58,
        theme: .dark
    )
    .padding()
    .background(AppTheme.dark.background)
}
