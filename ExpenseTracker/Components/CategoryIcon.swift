//
//  CategoryIcon.swift
//  ExpenseTracker
//
//  Created by Asal on 8/15/26.
//

import SwiftUI

struct CategoryIcon: View {
    
    let category: Category
    
    var body: some View {
        Image(systemName: iconName)
            .font(.title3)
    }
    
    private var iconName: String {
        switch category {
        case .food:
            return "fork.knife"
            
        case .transport:
            return "car.fill"
            
        case .shopping:
            return "bag.fill"
            
        case .entertainment:
            return "tv.fill"
            
        case .bills:
            return "doc.text.fill"
            
        case .education:
            return "book.fill"
            
        case .health:
            return "heart.fill"
            
        case .travel:
            return "airplane"
            
        case .other:
            return "ellipsis"
        }
    }
}
