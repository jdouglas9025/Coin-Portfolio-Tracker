import Foundation
import SwiftUI

// Defines the contract for a text color theme
protocol TextColorTheme {
    var primaryText: Color { get }
    var secondaryText: Color { get }
    
    var unchanged: Color { get }
    var background: Color { get }
    var primaryPopColor: Color { get }
    var secondaryPopColor: Color { get }
    var positive: Color { get }
    var negative: Color { get }
}

// Text Color Themes:
// Standard (black/white depending on background) text color theme
struct System: TextColorTheme {
    // Constants among all text colors (set by background color theme)
    let background = Color("BackgroundColor")
    let positive = Color("PositiveColor")
    let negative = Color("NegativeColor")
    let unchanged = Color("UnchangedColor")
    let primaryPopColor = Color("Standard/PrimaryPopColor")
    let secondaryPopColor = Color("Standard/SecondaryPopColor")
    
    var primaryText = Color("Standard/PrimaryTextColor")
    var secondaryText = Color("Standard/SecondaryTextColor")
}

// Light/dark blue text color theme
struct Blue: TextColorTheme {
    // Constants among all text colors (set by background color theme)
    let background = Color("BackgroundColor")
    let positive = Color("PositiveColor")
    let negative = Color("NegativeColor")
    let unchanged = Color("UnchangedColor")
    let primaryPopColor = Color("Blue/PrimaryPopColor")
    let secondaryPopColor = Color("Blue/SecondaryPopColor")
    
    var primaryText = Color("Blue/PrimaryTextColor")
    var secondaryText = Color("Blue/SecondaryTextColor")
}

// Light/dark green text color theme
struct Green: TextColorTheme {
    let background = Color("BackgroundColor")
    let positive = Color("PositiveColor")
    let negative = Color("NegativeColor")
    let unchanged = Color("UnchangedColor")
    let primaryPopColor = Color("Green/PrimaryPopColor")
    let secondaryPopColor = Color("Green/SecondaryPopColor")
    
    var primaryText = Color("Green/PrimaryTextColor")
    var secondaryText = Color("Green/SecondaryTextColor")
}

// Light/dark red text color theme
struct Red: TextColorTheme {
    let background = Color("BackgroundColor")
    let positive = Color("PositiveColor")
    let negative = Color("NegativeColor")
    let unchanged = Color("UnchangedColor")
    let primaryPopColor = Color("Red/PrimaryPopColor")
    let secondaryPopColor = Color("Red/SecondaryPopColor")
    
    var primaryText = Color("Red/PrimaryTextColor")
    var secondaryText = Color("Red/SecondaryTextColor")
}
