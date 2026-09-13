//
//  AnalyticsPlaceholderView.swift
//  ExpenseTracker
//

import SwiftUI

struct AnalyticsPlaceholderView: View {

    let theme: AppTheme

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(theme.primary)
                    Text("Analytics Coming Soon")
                        .font(.title2.bold())
                        .foregroundStyle(theme.text)
                    Text("Spending insights and category trends will arrive in Phase 5.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(theme.secondaryText)
                        .frame(maxWidth: 280)
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(theme.surface, for: .navigationBar)
            .toolbarColorScheme(theme.isDark ? .dark : .light, for: .navigationBar)
            .preferredColorScheme(theme.isDark ? .dark : .light)
        }
    }
}
