//
//  AnalyticsView.swift
//  ExpenseTracker
//

import Charts
import SwiftUI

enum AnalyticsRange: String, CaseIterable, Identifiable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case allTime = "All Time"

    var id: String { rawValue }
}

struct AnalyticsView: View {

    let expenses: [Expense]
    let theme: AppTheme

    @State private var selectedRange: AnalyticsRange = .thisMonth
    @AppStorage("currencyCode") private var currencyCode = AppCurrency.usd.rawValue

    private var currency: AppCurrency {
        AppCurrency(rawValue: currencyCode) ?? .usd
    }

    private var filteredExpenses: [Expense] {
        let now = Date()
        guard let startDate = startDate(for: selectedRange) else { return expenses }
        return expenses.filter { $0.date >= startDate && $0.date <= now }
    }

    private var totalExpenses: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    private var categoryBreakdown: [CategoryBreakdown] {
        let grouped = Dictionary(grouping: filteredExpenses, by: \.category)
        return grouped
            .map { category, expenses in
                CategoryBreakdown(
                    category: category,
                    total: expenses.reduce(0) { $0 + $1.amount },
                    grandTotal: totalExpenses
                )
            }
            .sorted { $0.total > $1.total }
    }

    private var trendPoints: [TrendPoint] {
        let calendar = Calendar.current
        let components = filteredExpenses.map { expense in
            TrendPoint(
                date: bucketDate(for: expense.date),
                amount: expense.amount
            )
        }

        return Dictionary(grouping: components, by: \.date)
            .map { date, points in
                TrendPoint(
                    date: date,
                    amount: points.reduce(0) { $0 + $1.amount }
                )
            }
            .sorted { $0.date < $1.date }
            .map { point in
                let normalizedDate = calendar.startOfDay(for: point.date)
                return TrendPoint(date: normalizedDate, amount: point.amount)
            }
    }

    private var activeDayCount: Int {
        Set(filteredExpenses.map { Calendar.current.startOfDay(for: $0.date) }).count
    }

    private var dailyAverage: Double {
        guard activeDayCount > 0 else { return 0 }
        return totalExpenses / Double(activeDayCount)
    }

    private var trendAverage: Double {
        guard !trendPoints.isEmpty else { return 0 }
        return totalExpenses / Double(trendPoints.count)
    }

    private var topCategory: CategoryBreakdown? {
        categoryBreakdown.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        rangePicker

                        if filteredExpenses.isEmpty {
                            emptyState
                        } else {
                            categoryChart
                            trendChart
                            insightsGrid
                            breakdownList
                        }
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(theme.surface, for: .navigationBar)
            .toolbarColorScheme(theme.isDark ? .dark : .light, for: .navigationBar)
            .preferredColorScheme(theme.isDark ? .dark : .light)
        }
    }

    private var rangePicker: some View {
        Picker("Time Range", selection: $selectedRange) {
            ForEach(AnalyticsRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .tint(theme.primary)
        .onChange(of: selectedRange) { _, _ in
            Haptics.light()
        }
    }

    private var categoryChart: some View {
        analyticsCard(title: "Category Breakdown", icon: "chart.pie.fill") {
            ZStack {
                Chart(categoryBreakdown) { item in
                    SectorMark(
                        angle: .value("Amount", item.total),
                        innerRadius: .ratio(0.62),
                        angularInset: 2
                    )
                    .foregroundStyle(categoryColor(for: item.category))
                }
                .chartLegend(.hidden)
                .frame(height: 230)

                VStack(spacing: 3) {
                    Text(totalExpenses.formattedCurrency(using: currency))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(theme.text)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text("Total Spent")
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                }
            }

            HStack(spacing: 12) {
                ForEach(categoryBreakdown.prefix(3)) { item in
                    HStack(spacing: 5) {
                        Circle()
                            .fill(categoryColor(for: item.category))
                            .frame(width: 7, height: 7)
                        Text(item.category.displayName)
                            .font(.caption)
                            .foregroundStyle(theme.secondaryText)
                            .lineLimit(1)
                    }
                }
            }
        }
    }

    private var trendChart: some View {
        analyticsCard(title: trendTitle, icon: "chart.bar.fill") {
            Chart {
                ForEach(trendPoints) { point in
                    BarMark(
                        x: .value("Date", point.date, unit: trendUnit),
                        y: .value("Spent", point.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.primary, theme.primary.opacity(0.48)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(5)
                }

                RuleMark(y: .value("Average", trendAverage))
                    .foregroundStyle(theme.warning.opacity(0.8))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 4]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Avg")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(theme.warning)
                    }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        .foregroundStyle(theme.surfaceElevated)
                    AxisValueLabel(format: trendAxisFormat)
                        .foregroundStyle(theme.secondaryText)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        .foregroundStyle(theme.surfaceElevated)
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(amount.formattedCurrency(using: currency))
                                .font(.caption2)
                                .foregroundStyle(theme.secondaryText)
                        }
                    }
                }
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(theme.surfaceElevated.opacity(0.18))
                    .cornerRadius(10)
            }
            .frame(height: 220)
        }
    }

    private var insightsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            insightCard(
                title: "Top Category",
                value: topCategory?.category.displayName ?? "—",
                detail: topCategory?.total.formattedCurrency(using: currency) ?? "No data",
                icon: topCategory.map { $0.category.iconName } ?? "chart.pie.fill",
                color: topCategory.map { categoryColor(for: $0.category) } ?? theme.primary
            )
            insightCard(
                title: "Daily Average",
                value: dailyAverage.formattedCurrency(using: currency),
                detail: activeDayCount == 1 ? "1 active day" : "\(activeDayCount) active days",
                icon: "calendar",
                color: theme.primary
            )
            insightCard(
                title: "Transaction Count",
                value: "\(filteredExpenses.count)",
                detail: "In selected range",
                icon: "number",
                color: theme.success
            )
        }
    }

    private var breakdownList: some View {
        analyticsCard(title: "Spending Breakdown", icon: "list.bullet.rectangle") {
            VStack(spacing: 14) {
                ForEach(categoryBreakdown) { item in
                    VStack(spacing: 8) {
                        HStack(spacing: 10) {
                            CategoryIcon(category: item.category)
                                .foregroundStyle(categoryColor(for: item.category))
                                .frame(width: 26)

                            Text(item.category.displayName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.text)

                            Spacer()

                            Text(item.total.formattedCurrency(using: currency))
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(theme.text)
                        }

                        HStack(spacing: 10) {
                            GeometryReader { proxy in
                                Capsule()
                                    .fill(theme.surfaceElevated)
                                    .overlay(alignment: .leading) {
                                        Capsule()
                                            .fill(categoryColor(for: item.category))
                                            .frame(width: proxy.size.width * item.percentage)
                                    }
                            }
                            .frame(height: 6)

                            Text("\(item.percentage * 100, specifier: "%.0f")%")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(theme.secondaryText)
                                .frame(width: 38, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 42))
                .foregroundStyle(theme.primary)
                .padding(20)
                .background(theme.primary.opacity(0.14), in: Circle())

            Text("No spending data yet")
                .font(.title3.bold())
                .foregroundStyle(theme.text)

            Text("Add expenses in this timeframe to unlock category insights and spending trends.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.secondaryText)
                .frame(maxWidth: 290)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 54)
        .padding(.horizontal, 20)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(theme.text.opacity(0.08), lineWidth: 1)
        }
    }

    private func analyticsCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(theme.primary)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(theme.text)
            }
            content()
        }
        .padding(18)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(theme.text.opacity(0.08), lineWidth: 1)
        }
    }

    private func insightCard(
        title: String,
        value: String,
        detail: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.14), in: RoundedRectangle(cornerRadius: 9))

            Text(title)
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
                .lineLimit(1)

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(theme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(detail)
                .font(.caption2)
                .foregroundStyle(theme.secondaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(theme.text.opacity(0.08), lineWidth: 1)
        }
    }

    private var trendTitle: String {
        selectedRange == .allTime ? "Weekly Spending Trend" : "Daily Spending Trend"
    }

    private var trendUnit: Calendar.Component {
        selectedRange == .allTime ? .weekOfYear : .day
    }

    private var trendAxisFormat: Date.FormatStyle {
        selectedRange == .allTime
            ? .dateTime.month(.abbreviated).day()
            : .dateTime.month(.abbreviated).day()
    }

    private func startDate(for range: AnalyticsRange) -> Date? {
        let calendar = Calendar.current
        switch range {
        case .thisWeek:
            return calendar.dateInterval(of: .weekOfYear, for: Date())?.start
        case .thisMonth:
            return calendar.dateInterval(of: .month, for: Date())?.start
        case .allTime:
            return nil
        }
    }

    private func bucketDate(for date: Date) -> Date {
        let calendar = Calendar.current
        switch selectedRange {
        case .allTime:
            return calendar.dateInterval(of: .weekOfYear, for: date)?.start
                ?? calendar.startOfDay(for: date)
        case .thisWeek, .thisMonth:
            return calendar.startOfDay(for: date)
        }
    }

    private func categoryColor(for category: Category) -> Color {
        switch category {
        case .food: return theme.success
        case .transport: return theme.primary
        case .shopping: return theme.warning
        case .entertainment: return theme.danger
        case .bills: return theme.secondaryText
        case .education: return theme.primarySoft
        case .health: return theme.success.opacity(0.72)
        case .travel: return theme.primary.opacity(0.72)
        case .other: return theme.text.opacity(0.58)
        }
    }
}

private struct CategoryBreakdown: Identifiable {
    let category: Category
    let total: Double
    let grandTotal: Double

    var id: String { category.id }

    var percentage: Double {
        guard grandTotal > 0 else { return 0 }
        return total / grandTotal
    }
}

private struct TrendPoint: Identifiable {
    let date: Date
    let amount: Double

    var id: Date { date }
}

#Preview {
    AnalyticsView(
        expenses: [
            Expense(title: "Coffee", amount: 5, category: .food, date: Date()),
            Expense(title: "Groceries", amount: 82, category: .shopping, date: Date()),
            Expense(title: "Taxi", amount: 18, category: .transport, date: Date())
        ],
        theme: .dark
    )
}
