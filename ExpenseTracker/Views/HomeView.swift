//
//  HomeView.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.


import SwiftUI
private var theme: AppTheme {
    switch themeMode {
    case .dark:
        return .dark
        
    case .light:
        return .light
    }
}

struct HomeView: View {
    
    @State private var themeMode: ThemeMode = .dark
    struct ExpenseRow: View {
        
        let expense: Expense
        let theme: AppTheme
    let expenses = [
        Expense(
            title: "Coffee",
            amount: 5,
            category: .food,
            date: Date()
        ),
        
        Expense(
            title: "Pizza",
            amount: 18.50,
            category: .food,
            date: Date()
        ),
        
        Expense(
            title: "Taxi",
            amount: 12,
            category: .transport,
            date: Date()
        )
    ]
    
    var body: some View {
        ZStack {
            
            theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                
                HStack {
                    Spacer()
                    
                    Button {
                        themeMode = themeMode == .dark ? .light : .dark
                    } label: {
                        Image(
                            systemName: themeMode == .dark
                            ? "sun.max.fill"
                            : "moon.fill"
                        )
                    }
                }
                
                ForEach(expenses) { expense in
                    ExpenseRow(
                        expense: expense,
                        theme: theme
                    )
                }
            .padding()
        }
    }
    

}

#Preview {
    HomeView()
}
