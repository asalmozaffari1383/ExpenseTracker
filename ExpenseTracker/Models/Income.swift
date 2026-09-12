//
//  Income.swift
//  ExpenseTracker
//

import Foundation

enum IncomeCategory: String, CaseIterable, Codable, Hashable, Identifiable {
    case salary
    case freelance
    case investment
    case gift
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .salary: return "Salary"
        case .freelance: return "Freelance"
        case .investment: return "Investment"
        case .gift: return "Gift"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .salary: return "briefcase.fill"
        case .freelance: return "laptopcomputer"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .gift: return "gift.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

struct Income: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var amount: Double
    var date: Date
    var sourceCategory: IncomeCategory

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date,
        sourceCategory: IncomeCategory
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.sourceCategory = sourceCategory
    }
}
