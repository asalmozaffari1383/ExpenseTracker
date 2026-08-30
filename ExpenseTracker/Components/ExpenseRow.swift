//
//  ExpenseRow.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.
//

import SwiftUI

struct ExpenseRow: View {
    
    let expense: Expense
    
    var body: some View {
        HStack {
            CategoryIcon(category: expense.category)
                .foregroundStyle(AppTheme.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.text)
                
                HStack(spacing: 4) {
                    Text(expense.category.rawValue.capitalized)
                    
                    Text("•")
                    
                    Text(expense.date, style: .date)
                }
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
            }
            
            Spacer()
            
            Text("$\(expense.amount, specifier: "%.2f")")
                .font(.headline)
                .foregroundStyle(AppTheme.text)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ExpenseRow(
        expense: Expense(
            title: "Coffee",
            amount: 5,
            category: .food,
            date: Date()
        ),
        theme: .dark
    )
}
