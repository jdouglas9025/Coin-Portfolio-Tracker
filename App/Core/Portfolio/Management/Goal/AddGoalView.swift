import SwiftUI

// Represents the view for adding a goal to the current portfolio
struct AddGoalView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    @ObservedObject private var goalInputValidationVM: GoalInputValidationViewModel
    
    // Used to return to parent view when cancel/save button clicked
    @Binding private var displayedView: PortfolioSelectionView.DisplayedView
    
    // Not validated in input VM since not free-form
    @State private var goalDate: Date = .now
    
    @FocusState private var focusedField: FocusedField?
    
    init(displayedView: Binding<PortfolioSelectionView.DisplayedView>) {
        _displayedView = displayedView
        
        // Init VM (needs to go before below code)
        self.goalInputValidationVM = GoalInputValidationViewModel(description: "", targetAmount: nil)
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Add Goal")
                    .font(.title)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
            }
            .padding(.horizontal)
            
            // Inputs
            VStack {
                VStack {
                    HStack {
                        Text("Description: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        TextField("I want to...", text: $goalInputValidationVM.description)
                            .foregroundStyle(goalInputValidationVM.description.isEmpty ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                            .focused($focusedField, equals: .first)
                            .keyboardType(.default)
                    }
                    .font(.headline)
                    
                    Text(goalInputValidationVM.descriptionPrompt)
                        .font(.caption)
                        .foregroundStyle(themeVM.textColorTheme.negative)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                }
                .multilineTextAlignment(.leading)
                .padding(.bottom)
                
                VStack {
                    HStack {
                        Text("Target Amount: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        TextField("$0", value: $goalInputValidationVM.targetAmount, format: GeneralUtility.intCurrencyFormatter)
                            .foregroundStyle(goalInputValidationVM.targetAmount == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                            .focused($focusedField, equals: .second)
                            .keyboardType(.numberPad)
                    }
                    .font(.headline)
                    
                    Text(goalInputValidationVM.targetAmountPrompt)
                        .font(.caption)
                        .foregroundStyle(themeVM.textColorTheme.negative)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()
                }
                .multilineTextAlignment(.leading)
                .padding(.bottom)
                
                // Date
                VStack(alignment: .leading) {
                    HStack {
                        Text("Target Date: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        // Allow selection of current day or day in future
                        DatePicker("Date", selection: $goalDate, in: Date.now..., displayedComponents: [.date])
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            // Hide label
                            .labelsHidden()
                    }
                    .font(.headline)

                    Divider()
                }
                .multilineTextAlignment(.leading)
                .padding(.bottom)
                
                actionButtons
            }
            .padding()
            .background(BackgroundRoundedRectangleView())
            .padding()
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    InputKeyboard(focusedField: $focusedField, numOfFields: 2)
                }
            }
        }
    }
}

extension AddGoalView {
    private var actionButtons: some View {
        HStack(alignment: .lastTextBaseline) {
            // Cancel
            Button(action: {
                // Return to edit portfolio view (not default portfolio overview)
                withAnimation(.easeInOut) {
                    UIApplication.shared.hideKeyboard()
                    displayedView = .editPortfolio
                }
            }, label: {
                CircleButtonView(iconName: "xmark", width: 40, height: 40)
            })

            Spacer()
            
            // Save (only show if valid)
            if goalInputValidationVM.allValidInputs {
                Button(action: {
                    homeVM.createGoal(goalDescription: goalInputValidationVM.description, goalTarget: Double(goalInputValidationVM.targetAmount ?? 0), goalDate: goalDate)
                    
                    withAnimation(.easeInOut) {
                        UIApplication.shared.hideKeyboard()
                        displayedView = .editPortfolio
                    }
                }, label: {
                    CircleButtonView(iconName: "checkmark", width: 40, height: 40)
                })
            }
        }
    }
}
