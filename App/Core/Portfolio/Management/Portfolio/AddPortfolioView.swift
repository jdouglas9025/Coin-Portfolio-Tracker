import SwiftUI

// Sub-view inside portfolio selection view to create a new portfolio
struct AddPortfolioView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var primaryVM: PrimaryViewModel
    
    @ObservedObject var portfolioInputValidationVM: PortfolioInputValidationViewModel
    
    @Binding var displayedView: PortfolioSelectionView.DisplayedView
    
    var body: some View {
        VStack {
            Text("Create")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Inputs
            VStack {
                VStack {
                    HStack {
                        Text("Name: ")
                            .font(.headline)
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        HStack {
                            TextField("New Portfolio", text: $portfolioInputValidationVM.updatedName)
                                .font(.headline)
                                .foregroundStyle(portfolioInputValidationVM.updatedName.isEmpty ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                .keyboardType(.default)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .multilineTextAlignment(.leading)
                    }
                    
                    Text(portfolioInputValidationVM.updatedNamePrompt)
                        .font(.caption)
                        .foregroundStyle(themeVM.textColorTheme.negative)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Divider()
                }
                .padding(.bottom)
                
                addButtons
            }
            .padding()
            .background(BackgroundRoundedRectangleView())
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    keyboard
                }
            }
        }
        .padding(.horizontal)
    }
}

extension AddPortfolioView {
    private var addButtons: some View {
        HStack() {
            Button(action: {
                withAnimation(.easeInOut) {
                    UIApplication.shared.hideKeyboard()
                    portfolioInputValidationVM.updatedName = ""
                    displayedView = .overview
                }
            }, label: {
                CircleButtonView(iconName: "xmark", width: 40, height: 40)
            })
            
            Spacer()
            
            // Save (only show if valid)
            if portfolioInputValidationVM.allValidInputs {
                Button(action: {
                    // Create portfolio
                    primaryVM.createPortfolio(name: portfolioInputValidationVM.updatedName)
                    
                    withAnimation(.easeInOut) {
                        UIApplication.shared.hideKeyboard()
                        portfolioInputValidationVM.updatedName = ""
                        displayedView = .overview
                    }
                }, label: {
                    CircleButtonView(iconName: "checkmark", width: 40, height: 40)
                })
            }
        }
    }
    
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
