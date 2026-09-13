//
//  AppCurrency.swift
//  ExpenseTracker
//

import Foundation

enum AppCurrency: String, CaseIterable, Identifiable {
    case usd = "USD"
    case irr = "IRR"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .usd: return "Dollar"
        case .irr: return "Rial"
        }
    }

    var inputSuffix: String {
        switch self {
        case .usd: return "$"
        case .irr: return "تومان"
        }
    }

    func formatted(_ amount: Double) -> String {
        switch self {
        case .usd:
            return Self.usdFormatter.string(from: NSNumber(value: amount)) ?? "$0.00"
        case .irr:
            let roundedAmount = amount.rounded()
            let value = Self.integerFormatter.string(from: NSNumber(value: roundedAmount)) ?? "0"
            return "\(value) T"
        }
    }

    private static let usdFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private static let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

extension Double {
    func formattedCurrency(using currency: AppCurrency) -> String {
        currency.formatted(self)
    }
}
