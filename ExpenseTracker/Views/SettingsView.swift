//
//  SettingsView.swift
//  ExpenseTracker
//

import SwiftUI

struct SettingsView: View {

    @Binding var themeMode: ThemeMode
    @Binding var monthlyBudget: Double
    let theme: AppTheme

    @State private var budgetText = ""

    private var isBudgetValid: Bool {
        guard let budget = Double(budgetText) else { return false }
        return budget >= 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    settingsSectionTitle("Appearance")
                    HStack(spacing: 14) {
                        Image(systemName: themeMode == .dark ? "moon.fill" : "sun.max.fill")
                            .foregroundStyle(theme.primary)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Dark Mode")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.text)
                            Text("Use the low-glare fintech palette")
                                .font(.caption)
                                .foregroundStyle(theme.secondaryText)
                        }
                        Spacer()
                        Toggle(
                            "Dark Mode",
                            isOn: Binding(
                                get: { themeMode == .dark },
                                set: {
                                    Haptics.light()
                                    themeMode = $0 ? .dark : .light
                                }
                            )
                        )
                        .labelsHidden()
                        .tint(theme.primary)
                    }
                    .padding(16)
                    .background(theme.surface, in: RoundedRectangle(cornerRadius: 17))
                    .overlay {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(theme.text.opacity(0.08), lineWidth: 1)
                    }

                    settingsSectionTitle("Budget")
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.67percent")
                                .foregroundStyle(theme.primary)
                                .frame(width: 24)
                            Text("Monthly limit")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.text)
                            Spacer()
                            TextField("0.00", text: $budgetText)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(theme.text)
                                .frame(width: 110)
                        }

                        Divider().overlay(theme.surfaceElevated)

                        Button {
                            saveBudget()
                        } label: {
                            Label("Save Budget", systemImage: "checkmark")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(theme.primary)
                        .disabled(!isBudgetValid)
                    }
                    .padding(16)
                    .background(theme.surface, in: RoundedRectangle(cornerRadius: 17))
                    .overlay {
                        RoundedRectangle(cornerRadius: 17)
                            .strokeBorder(theme.text.opacity(0.08), lineWidth: 1)
                    }

                    Text("Your budget updates the dashboard progress and health indicator instantly.")
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                }
                .padding()
            }
            .background(theme.background)
            .tint(theme.primary)
            .navigationTitle("Settings")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(theme.surface, for: .navigationBar)
            .toolbarColorScheme(theme.isDark ? .dark : .light, for: .navigationBar)
            .scrollIndicators(.hidden)
            .preferredColorScheme(theme.isDark ? .dark : .light)
            .onAppear {
                budgetText = String(format: "%.2f", monthlyBudget)
            }
        }
    }

    private func saveBudget() {
        guard let budget = Double(budgetText), budget >= 0 else { return }
        monthlyBudget = budget
        budgetText = String(format: "%.2f", budget)
        Haptics.light()
    }

    private func settingsSectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .tracking(1.1)
            .foregroundStyle(theme.secondaryText)
    }
}
