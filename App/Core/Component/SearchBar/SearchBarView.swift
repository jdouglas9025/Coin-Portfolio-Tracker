import SwiftUI

struct SearchBarView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    // Current text
    @Binding var searchBarText: String
    
    let padding: Double
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(searchBarText.isEmpty ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
            
            HStack {
                TextField("Search", text: $searchBarText)
                    .foregroundStyle(searchBarText.isEmpty ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                    .keyboardType(.default)
                
                ClearStringButtonView(input: $searchBarText)
            }
            .multilineTextAlignment(.leading)
        }
        .font(.headline)
        .padding(10)
        .background(BackgroundRoundedRectangleView())
        .padding(padding)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                keyboard
            }
        }
    }
}

extension SearchBarView {
    private var keyboard: some View {
        HStack {
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut) {
                    UIApplication.shared.hideKeyboard()
                }
            }, label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
            })
        }
    }
}
