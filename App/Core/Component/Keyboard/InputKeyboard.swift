import SwiftUI

enum FocusedField: Hashable {
    case first, second, third, fourth
}

struct InputKeyboard: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    // Focus state to control from parent view
    @FocusState.Binding var focusedField: FocusedField?
    // Some forms require 2 vs. 3 fields
    let numOfFields: Int
    
    var body: some View {
        if numOfFields == 2 {
            twoFields
        } else if numOfFields == 3 {
            threeFields
        } else if numOfFields == 4 {
            fourFields
        }
    }
}

extension InputKeyboard {
    // Keyboard for forms with two fields
    private var twoFields: some View {
        HStack {
            // Up arrow
            Button(action: {
                withAnimation(.easeInOut) {
                    if focusedField == .second {
                        focusedField = .first
                    }
                }
            }, label: {
                Image(systemName: "chevron.up")
                    .font(.headline)
                    .foregroundStyle(focusedField == .first ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
            })
            .opacity(focusedField == .first ? 0.70 : 1.0)
            .disabled(focusedField == .first ? true : false)
            
            // Down arrow
            Button(action: {
                withAnimation(.easeInOut) {
                    if focusedField == .first {
                        focusedField = .second
                    }
                }
            }, label: {
                Image(systemName: "chevron.down")
                    .font(.headline)
                    .foregroundStyle(focusedField == .second ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
            })
            .opacity(focusedField == .second ? 0.70 : 1.0)
            .disabled(focusedField == .second ? true : false)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut) {
                    focusedField = nil
                }
            }, label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
            })
        }
    }
    
    // Keyboard for forms with three fields
    private var threeFields: some View {
        HStack {
            // Up arrow
            Button(action: {
                withAnimation(.easeInOut) {
                    if focusedField == .second {
                        focusedField = .first
                    } else if focusedField == .third {
                        focusedField = .second
                    }
                }
            }, label: {
                Image(systemName: "chevron.up")
                    .font(.headline)
                    .foregroundStyle(focusedField == .first ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
            })
            .opacity(focusedField == .first ? 0.70 : 1.0)
            .disabled(focusedField == .first ? true : false)
            
            // Down arrow
            Button(action: {
                withAnimation(.easeInOut) {
                    if focusedField == .first {
                        focusedField = .second
                    } else if focusedField == .second {
                        focusedField = .third
                    }
                }
            }, label: {
                Image(systemName: "chevron.down")
                    .font(.headline)
                    .foregroundStyle(focusedField == .third ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
            })
            .opacity(focusedField == .third ? 0.70 : 1.0)
            .disabled(focusedField == .third ? true : false)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut) {
                    focusedField = nil
                }
            }, label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
            })
        }
    }
    
    // Keyboard for forms with four fields
    private var fourFields: some View {
        HStack {
            // Up arrow
            Button(action: {
                withAnimation(.easeInOut) {
                    if focusedField == .second {
                        focusedField = .first
                    } else if focusedField == .third {
                        focusedField = .second
                    } else if focusedField == .fourth {
                        focusedField = .third
                    }
                }
            }, label: {
                Image(systemName: "chevron.up")
                    .font(.headline)
                    .foregroundStyle(focusedField == .first ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
            })
            .opacity(focusedField == .first ? 0.70 : 1.0)
            .disabled(focusedField == .first ? true : false)
            
            // Down arrow
            Button(action: {
                withAnimation(.easeInOut) {
                    if focusedField == .first {
                        focusedField = .second
                    } else if focusedField == .second {
                        focusedField = .third
                    } else if focusedField == .third {
                        focusedField = .fourth
                    }
                }
            }, label: {
                Image(systemName: "chevron.down")
                    .font(.headline)
                    .foregroundStyle(focusedField == .fourth ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
            })
            .opacity(focusedField == .fourth ? 0.70 : 1.0)
            .disabled(focusedField == .fourth ? true : false)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut) {
                    focusedField = nil
                }
            }, label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
            })
        }
    }
}
