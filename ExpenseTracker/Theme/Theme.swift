//
//  Theme.swift
//  ExpenseTracker
//
//  Created by Asal on 8/22/26.
//

import SwiftUI

struct AppTheme {
    
    let background: Color
    let surface: Color
    let surfaceElevated: Color
    
    let primary: Color
    let primarySoft: Color
    
    let text: Color
    let secondaryText: Color
    
    let success: Color
    let warning: Color
    let danger: Color
}

extension AppTheme {
    
    static let dark = AppTheme(
        background: Color(hex: "0D0F14"),
        surface: Color(hex: "151820"),
        surfaceElevated: Color(hex: "1C2029"),
        
        primary: Color(hex: "4F7CFF"),
        primarySoft: Color(hex: "26365F"),
        
        text: Color(hex: "F5F7FA"),
        secondaryText: Color(hex: "969EAD"),
        
        success: Color(hex: "45D483"),
        warning: Color(hex: "FFB84D"),
        danger: Color(hex: "FF5C67")
    )
    
    static let light = AppTheme(
        background: Color(hex: "F5F7FA"),
        surface: Color(hex: "FFFFFF"),
        surfaceElevated: Color(hex: "E9EDF3"),
        
        primary: Color(hex: "4F7CFF"),
        primarySoft: Color(hex: "DCE5FF"),
        
        text: Color(hex: "111318"),
        secondaryText: Color(hex: "687080"),
        
        success: Color(hex: "22A861"),
        warning: Color(hex: "D88A00"),
        danger: Color(hex: "D93644")
    )
}
