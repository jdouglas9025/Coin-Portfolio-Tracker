import SwiftUI

// View for selecting theme (background + text color + text size) in Settings view
struct ThemeSelectorView: View {
    // System dark/light mode from settings
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var landingVM: LandingViewModel
    
    let itemPadding = 5.0
    
    var body: some View {
        // Background color theme
        VStack {
            let useColorScheme = (colorScheme == .dark) ? Color.dark : Color.light
            let useBackgroundColorTheme = (themeVM.backgroundColorTheme == .dark) ? Color.dark : Color.light
            
            Circle()
                .fill(
                    ((themeVM.backgroundColorTheme == nil) ? useColorScheme : useBackgroundColorTheme)
                        .gradient
                )
                .shadow(color: themeVM.textColorTheme.primaryText, radius: 1.5)
                .frame(width: 100, height: 100, alignment: .center)
            
            Text("Background Color")
                .padding(.top)
                .font(.headline)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
            
            HStack(spacing: 0) {
                ForEach(SelectedBackgroundColorTheme.allCases, id: \.rawValue) { backgroundColorTheme in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            // Reload not necessary since no lag, but to be consistent
                            landingVM.showReloadScreen = true
                            themeVM.updateBackgroundColorTheme(selectedBackgroundColorTheme: backgroundColorTheme)
                        }
                    }, label: {
                        Text(backgroundColorTheme.rawValue)
                            .font(.headline)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .padding(itemPadding)
                            .frame(width: 80, height: 32)
                            .background(
                                Capsule()
                                    .foregroundStyle(themeVM.textColorTheme.background)
                                    // Only show for currently selected item
                                    .opacity((themeVM.getSelectedBackgroundColorTheme() == backgroundColorTheme) ? 1.0 : 0.0)
                            )
                    })
                }
            }
            .padding(itemPadding)
            .background(
                Capsule()
                    .fill(themeVM.textColorTheme.secondaryText.opacity(0.60))
            )
        }
        .padding(.bottom)
        
        VStack {
            VStack {
                // Primary text
                Text("This is some important text!")
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Secondary Text
                Text("This is some less important text.")
                    .font(.caption)
                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            // Text size
            Text("Text Size")
                .padding(.top)
                .font(.headline)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
            
            HStack(spacing: 5) {
                // Decrease
                Button {
                    withAnimation(.easeInOut) {
                        // Show reload screen while views are reloading to prevent lag
                        landingVM.showReloadScreen = true
                        themeVM.decreaseTextSizeTheme()
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.headline)
                        .foregroundStyle(themeVM.getSelectedTextSizeTheme() == SelectedTextSizeTheme.small ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                        .padding(itemPadding)
                        .frame(width: 80, height: 32)
                        .background(
                            Capsule()
                                .foregroundStyle(themeVM.textColorTheme.background)
                                // Dim if disabled
                                .opacity(themeVM.getSelectedTextSizeTheme() == SelectedTextSizeTheme.small ? 0.0 : 1.0)
                        )
                }
                // Disable if text size is min
                .disabled(themeVM.getSelectedTextSizeTheme() == SelectedTextSizeTheme.small ? true : false)
                
                // Increase
                Button {
                    withAnimation(.easeInOut) {
                        landingVM.showReloadScreen = true
                        themeVM.increaseTextSizeTheme()
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(themeVM.getSelectedTextSizeTheme() == SelectedTextSizeTheme.xxLarge ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                        .padding(itemPadding)
                        .frame(width: 80, height: 32)
                        .background(
                            Capsule()
                                .foregroundStyle(themeVM.textColorTheme.background)
                                // Dim if disabled
                                .opacity(themeVM.getSelectedTextSizeTheme() == SelectedTextSizeTheme.xxLarge ? 0.0 : 1.0)
                        )
                }
                // Disable if text size is max
                .disabled(themeVM.getSelectedTextSizeTheme() == SelectedTextSizeTheme.xxLarge ? true : false)
            }
            .padding(itemPadding)
            .background(
                Capsule()
                    .fill(themeVM.textColorTheme.secondaryText.opacity(0.60))
            )
            
            // Text color theme
            Text("Text Color")
                .padding(.top)
                .font(.headline)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
            
            HStack(spacing: 0) {
                ForEach(SelectedTextColorTheme.allCases, id: \.rawValue) { textColorTheme in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            landingVM.showReloadScreen = true
                            themeVM.updateTextColorTheme(selectedTextColorTheme: textColorTheme)
                        }
                    }, label: {
                        Text(textColorTheme.rawValue)
                            .font(.headline)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .padding(itemPadding)
                            .frame(width: 80, height: 32)
                            .background(
                                Capsule()
                                    .foregroundStyle(themeVM.textColorTheme.background)
                                    //Only show for currently selected item
                                    .opacity((themeVM.getSelectedTextColorTheme() == textColorTheme) ? 1.0 : 0.0)
                            )
                    })
                }
            }
            .padding(itemPadding)
            .background(
                Capsule()
                    .fill(themeVM.textColorTheme.secondaryText.opacity(0.60))
            )
        }
        .padding(.bottom)
    }
}
