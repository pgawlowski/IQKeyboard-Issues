import Foundation

class DefaultInputFormatValidation {

    enum ValidationType {
        case email
        case password
        case nickname
        case pesel
        case required
    }

    var validationType: [ValidationType] = []

    func isValid(input: String?) -> Bool? {
        var result: Bool = true

        for type in validationType {
            switch type {
            case .email:
                result = result && isValidEmailFormat(email: input)
            case .password:
                result = result && isValidPassword(password: input)
            case .nickname:
                result = result && isValidNickname(nickname: input)
            case .required:
                result = result && isValidRequired(input: input)
            case .pesel:
                result = result && isValidPesel(pesel: input)
            }
        }

        return result
    }

    private func isValidEmailFormat(email: String?) -> Bool {
        guard let email = email, !email.isEmpty else {
            return false
        }
        let emailRegEx =
            "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
                "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
                "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
                "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
                "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
                "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

        let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    //Paswword has: min. 8 characters, one upper case, one special character or number
    private func isValidPassword(password: String?) -> Bool {
        guard let password = password, !password.isEmpty else {
            return false
        }

        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let capitalTest = NSPredicate(format: "SELF MATCHES %@", capitalLetterRegEx)
        guard capitalTest.evaluate(with: password) else { return false }

        let specialCharacterRegEx  = ".*[!&^%$#@()/_*+-]+.*"
        let specialTest = NSPredicate(format: "SELF MATCHES %@", specialCharacterRegEx)
        let numberRegEx  = ".*[0-9]+.*"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegEx)

        guard specialTest.evaluate(with: password) || numberTest.evaluate(with: password) else { return false }

        return password.count >= 8
    }

    private func isValidNickname(nickname: String?) -> Bool {
        guard let nickname = nickname, !nickname.isEmpty else {
            return true
        }
        return nickname.count > 7
    }

    func isValidPesel(pesel: String?) -> Bool {
        guard let pesel = pesel else { return false }

        let ints = pesel.compactMap { Int(String($0)) }
        guard ints.count == 11 else { return false }

        let weights = [1, 3, 7, 9, 1, 3, 7, 9, 1, 3, 1]
        var sum = 0
        var checksumValue: Int = 0

        for index in 0...9 {
            sum += weights[index] * ints[index]
        }

        let checksum = 10 - (sum % 10)
        checksumValue = (checksum == 10) ? 0 : checksum

        if ints.last != checksumValue {
            return false
        }

        return true
    }

    private func isValidRequired(input: String?) -> Bool {
        guard let input = input else { return false }

        return !input.isEmpty
    }

}
