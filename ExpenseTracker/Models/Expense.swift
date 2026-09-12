//
//  Expens.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.
//

import Foundation

struct Expense: Identifiable {
    let id: UUID
    var title: String
    var amount: Double
    var category: Category
    var date: Date

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        category: Category,
        date: Date
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
    }
}
