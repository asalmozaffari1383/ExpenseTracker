//
//  Expens.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.
//

import Foundation

struct Expense: Identifiable {
    let id = UUID()
    var title: String
    var amount: Double
    var category: Category
    var date: Date
}
