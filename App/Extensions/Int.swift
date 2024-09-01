import Foundation

extension Int {
    func asCondensedNumber() -> String {
        return GeneralUtility.condensedIntFormatter.format(self)
    }
}
