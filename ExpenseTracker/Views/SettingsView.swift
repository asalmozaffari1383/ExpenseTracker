//
//  SettingsView.swift
//  ExpenseTracker
//

import SwiftUI

struct SettingsView: View {

    @Binding var themeMode: ThemeMode
    let theme: AppTheme
    let transactionCount: Int
    let onDeleteAllData: () -> Void

    @AppStorage("themeMode") private var themeModeRawValue = ThemeMode.dark.rawValue
    @AppStorage("monthlyBudgetLimit") private var monthlyBudgetLimit: Double = 2_000.0
    @AppStorage("currencyCode") private var currencyCode = AppCurrency.usd.rawValue
    @State private var budgetInputText = ""
    @State private var showSuccessAlert = false
    @State private var showDeleteDataConfirmation = false
    @State private var hasEditedBudget = false
    @FocusState private var isBudgetFieldFocused: Bool

    init(
        themeMode: Binding<ThemeMode>,
        theme: AppTheme,
        transactionCount: Int = 0,
        onDeleteAllData: @escaping () -> Void = {}
    ) {
        self._themeMode = themeMode
        self.theme = theme
        self.transactionCount = transactionCount
        self.onDeleteAllData = onDeleteAllData
    }

    private var parsedBudget: Double? {
        let normalizedText = budgetInputText
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(normalizedText)
    }

    private var isBudgetValid: Bool {
        guard let parsedBudget else { return false }
        return parsedBudget > 0 && parsedBudget.isFinite
    }

    private var selectedCurrency: AppCurrency {
        AppCurrency(rawValue: currencyCode) ?? .usd
    }

    private var storedThemeMode: ThemeMode {
        ThemeMode(rawValue: themeModeRawValue) ?? .dark
    }

    private var budgetValidationMessage: String? {
        guard hasEditedBudget else { return nil }
        guard let parsedBudget else {
            return budgetInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "Enter a budget amount."
                : "Enter a valid number."
        }
        guard parsedBudget.isFinite else { return "Enter a valid number." }
        guard parsedBudget > 0 else { return "Budget must be greater than zero." }
        return nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    settingsSectionTitle("Appearance")
                    appearanceCard

                    settingsSectionTitle("Budget")
                    budgetCard

                    settingsSectionTitle("General Information")
                    generalInfoCard
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .background(theme.background)
            .tint(theme.primary)
            .navigationTitle("Settings")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(theme.surface, for: .navigationBar)
            .toolbarColorScheme(theme.isDark ? .dark : .light, for: .navigationBar)
            .preferredColorScheme(theme.isDark ? .dark : .light)
            .onAppear {
                budgetInputText = formattedBudget(monthlyBudgetLimit)
            }
            .alert("Budget Updated", isPresented: $showSuccessAlert) {
                Button("Done", role: .cancel) { }
            } message: {
                Text("Your new monthly budget is now applied to the dashboard.")
            }
            .confirmationDialog(
                "Delete All Data?",
                isPresented: $showDeleteDataConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All Data", role: .destructive) {
                    onDeleteAllData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This permanently removes all saved income and expense transactions.")
            }
        }
    }

    private var appearanceCard: some View {
        HStack(spacing: 14) {
            Image(systemName: storedThemeMode == .dark ? "moon.fill" : "sun.max.fill")
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
                    get: { storedThemeMode == .dark },
                    set: {
                        Haptics.light()
                        let newMode: ThemeMode = $0 ? .dark : .light
                        themeMode = newMode
                        themeModeRawValue = newMode.rawValue
                    }
                )
            )
            .labelsHidden()
            .tint(theme.primary)
        }
        .padding(16)
        .themedCard(theme: theme)
    }

    private var budgetCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "banknote.fill")
                    .foregroundStyle(theme.primary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Current Monthly Budget")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.text)
                    Text(monthlyBudgetLimit.formattedCurrency(using: selectedCurrency))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(theme.primary)
                }

                Spacer()
            }

            Divider().overlay(theme.surfaceElevated)

            HStack(spacing: 10) {
                TextField(
                    "Enter budget limit (\(selectedCurrency.inputSuffix))",
                    text: budgetInputBinding
                )
                    .keyboardType(.decimalPad)
                    .focused($isBudgetFieldFocused)
                    .submitLabel(.done)
                    .foregroundStyle(theme.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(theme.background, in: RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(theme.text.opacity(0.12), lineWidth: 1)
                    }

                Button("Save", action: saveBudget)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(theme.isDark ? theme.background : theme.text)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(theme.primary, in: RoundedRectangle(cornerRadius: 12))
                    .opacity(isBudgetValid ? 1 : 0.7)
            }

            Picker("Currency", selection: $currencyCode) {
                ForEach(AppCurrency.allCases) { currency in
                    Text(currency.displayName).tag(currency.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: currencyCode) { _, _ in
                Haptics.light()
            }

            if let budgetValidationMessage {
                Label(budgetValidationMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(theme.danger)
            }
        }
        .padding(18)
        .themedCard(theme: theme)
    }

    private var generalInfoCard: some View {
        VStack(spacing: 14) {
            VStack(spacing: 14) {
                SettingInfoRow(
                    icon: "app.badge.fill",
                    title: "App Version",
                    value: "1.0.0",
                    theme: theme
                )
                Divider().overlay(theme.surfaceElevated)
                SettingInfoRow(
                    icon: "laptopcomputer",
                    title: "Architecture",
                    value: "SwiftUI",
                    theme: theme
                )
                Divider().overlay(theme.surfaceElevated)
                SettingInfoRow(
                    icon: "internaldrive.fill",
                    title: "Budget Storage",
                    value: "AppStorage",
                    theme: theme
                )
                Divider().overlay(theme.surfaceElevated)
                SettingInfoRow(
                    icon: "list.number",
                    title: "Transactions",
                    value: "\(transactionCount)",
                    theme: theme
                )
            }
            .padding(18)
            .themedCard(theme: theme)

            Button {
                showDeleteDataConfirmation = true
            } label: {
                Label("Delete All Data", systemImage: "trash")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
            }
            .buttonStyle(.bordered)
            .tint(theme.danger)
        }
    }

    private func saveBudget() {
        hasEditedBudget = true
        guard let parsedBudget, parsedBudget > 0, parsedBudget.isFinite else { return }
        monthlyBudgetLimit = parsedBudget
        budgetInputText = formattedBudget(parsedBudget)
        isBudgetFieldFocused = false
        Haptics.light()
        showSuccessAlert = true
    }

    private var budgetInputBinding: Binding<String> {
        Binding(
            get: { budgetInputText },
            set: {
                hasEditedBudget = true
                budgetInputText = formatInput($0)
            }
        )
    }

    private func formatInput(_ input: String) -> String {
        let normalized = input.replacingOccurrences(of: ",", with: "")
        let components = normalized.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let integerDigits = components.first?.filter(\.isNumber) ?? ""
        let groupedInteger = groupDigits(String(integerDigits))

        guard components.count == 2 else { return groupedInteger }
        let decimalDigits = components[1].filter(\.isNumber).prefix(2)
        return "\(groupedInteger).\(decimalDigits)"
    }

    private func groupDigits(_ digits: String) -> String {
        guard !digits.isEmpty else { return "" }
        var groups: [String] = []
        var remaining = digits
        while remaining.count > 3 {
            let splitIndex = remaining.index(remaining.endIndex, offsetBy: -3)
            groups.insert(String(remaining[splitIndex...]), at: 0)
            remaining = String(remaining[..<splitIndex])
        }
        groups.insert(remaining, at: 0)
        return groups.joined(separator: ",")
    }

    private func formattedBudget(_ amount: Double) -> String {
        String(format: "%.2f", amount)
    }

    private func settingsSectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .tracking(1.1)
            .foregroundStyle(theme.secondaryText)
    }
}

private struct SettingInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(theme.secondaryText)
                .frame(width: 24)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(theme.text)

            Spacer(minLength: 12)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(theme.secondaryText)
                .multilineTextAlignment(.trailing)
        }
    }
}

private extension View {
    func themedCard(theme: AppTheme) -> some View {
        background(theme.surface, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(theme.text.opacity(0.08), lineWidth: 1)
            }
    }
}

#Preview {
    SettingsView(themeMode: .constant(.dark), theme: .dark)
}
