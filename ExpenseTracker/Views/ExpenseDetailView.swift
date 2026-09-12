//
//  ExpenseDetailView.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.
//

import SwiftUI

struct ExpenseDetailView: View {
    
    let expense: Expense
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(expense.category.displayName)
                .font(.headline)
            
            Text(expense.title)
                .font(.largeTitle.bold())
            
            Text("$\(expense.amount, specifier: "%.2f")")
                .font(.title)
            
            Text(expense.date, style: .date)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Expense Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ExpenseDetailView(
        expense: Expense(
            title: "Coffee",
            amount: 5,
            category: .food,
            date: Date()
        )
    )
}
