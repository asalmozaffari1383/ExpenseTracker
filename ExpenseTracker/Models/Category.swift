//
//  Category.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.
//

import Foundation

enum Category: String, CaseIterable, Identifiable {
    case food
    case transport
    case shopping
    case entertainment
    case bills
    case education
    case health
    case travel
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .food: return "Food"
        case .transport: return "Transport"
        case .shopping: return "Shopping"
        case .entertainment: return "Entertainment"
        case .bills: return "Bills"
        case .education: return "Education"
        case .health: return "Health"
        case .travel: return "Travel"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "tv.fill"
        case .bills: return "doc.text.fill"
        case .education: return "book.fill"
        case .health: return "heart.fill"
        case .travel: return "airplane"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
