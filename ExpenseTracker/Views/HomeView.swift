//
//  HomeView.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.
//

import SwiftUI

struct HomeView: View {
    
    @State private var themeMode: ThemeMode = .dark
    @State private var showingAddExpense = false
    
    @State private var expenses: [Expense] = [
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
    
    private var theme: AppTheme {
        switch themeMode {
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    
                    // MARK: - Header
                    
                    HStack {
                        Text("Expenses")
                            .font(.largeTitle.bold())
                            .foregroundStyle(theme.text)
                        
                        Spacer()
                        
                        // Theme Button
                        Button {
                            themeMode = themeMode == .dark ? .light : .dark
                        } label: {
                            Image(
                                systemName: themeMode == .dark
                                ? "sun.max.fill"
                                : "moon.fill"
                            )
                            .font(.title3)
                            .foregroundStyle(theme.text)
                        }
                        .accessibilityLabel("Toggle color theme")
                        
                        // Add Expense Button
                        Button {
                            showingAddExpense = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.blue)
                        }
                        .padding(.leading, 8)
                    }
                    
                    // MARK: - Expense List
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(expenses) { expense in
                                NavigationLink {
                                    ExpenseDetailView(expense: expense)
                                } label: {
                                    ExpenseRow(
                                        expense: expense,
                                        theme: theme
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView { newExpense in
                expenses.insert(newExpense, at: 0)
            }
        }
    }
}

#Preview {
    HomeView()
}
