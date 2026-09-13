//
//  FinancialSummaryCard.swift
//  ExpenseTracker
//

import SwiftUI

struct FinancialSummaryCard: View {

    let balance: Double
    let totalIncome: Double
    let totalExpense: Double
    let theme: AppTheme
    @AppStorage("currencyCode") private var currencyCode = AppCurrency.usd.rawValue

    private var currency: AppCurrency {
        AppCurrency(rawValue: currencyCode) ?? .usd
    }

    private var balanceColor: Color {
        balance >= 0 ? theme.success : theme.danger
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Net Balance")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)

                    Text(balance.formattedCurrency(using: currency))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(balanceColor)
                }

                Spacer()

                Image(systemName: balance >= 0
                      ? "chart.line.uptrend.xyaxis"
                      : "chart.line.downtrend.xyaxis")
                    .font(.title2)
                    .foregroundStyle(balanceColor)
                    .padding(12)
                    .background(balanceColor.opacity(0.14), in: Circle())
            }

            HStack(spacing: 12) {
                amountBadge(
                    title: "Income",
                    amount: totalIncome,
                    icon: "arrow.down.left",
                    color: theme.success
                )
                amountBadge(
                    title: "Expenses",
                    amount: totalExpense,
                    icon: "arrow.up.right",
                    color: theme.danger
                )
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(theme.surface)
                .overlay {
                    LinearGradient(
                        colors: [theme.primary.opacity(0.16), theme.success.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(theme.text.opacity(0.08), lineWidth: 1)
        }
    }

    private func amountBadge(
        title: String,
        amount: Double,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .padding(7)
                .background(color.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
                Text(amount.formattedCurrency(using: currency))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(theme.surfaceElevated, in: RoundedRectangle(cornerRadius: 13))
    }
}

#Preview {
    FinancialSummaryCard(
        balance: 1_284.50,
        totalIncome: 2_500,
        totalExpense: 1_215.50,
        theme: .dark
    )
    .padding()
    .background(AppTheme.dark.background)
}
