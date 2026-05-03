//
//  LoginService.swift
//  homework4
//
//  Created by Максим  on 28.04.2026.
//

import Foundation

protocol LoginServiceProtocol {
    var mode: LoginServiceMode { get }
    
    func tryLogUserIn(userCredentials: UserCredentials) throws
    func changeMode(to mode: LoginServiceMode)
    func previouslyLoggedUser() -> String?
}

final class LoginService: LoginServiceProtocol {
    private(set) var mode: LoginServiceMode
    
    private let defaultsStorage = DefaultsStorageService()
    private let keyChainService = Keychain()
    
    init(initialMode: LoginServiceMode) {
        mode = initialMode
    }
    
    func previouslyLoggedUser() -> String? {
        return defaultsStorage.loggedUser
    }
    
    func tryLogUserIn(userCredentials: UserCredentials) throws {
        switch mode {
        case .login:
            do {
                guard doesUserExist(username: userCredentials.username) else { throw LoginError.userDoesNotExtist }
                guard isPasswordIsCorrect(userCredentials) else { throw LoginError.invalidCredentials }
            } catch {
                throw error
            }
        case .register:
            do {
                try validateRegistrationCredeitials(userCredentials)
                try registerUser(userCredentials)
            } catch {
                throw error
            }
        }
        defaultsStorage.loggedUser = userCredentials.username
    }
    
    func changeMode(to mode: LoginServiceMode) {
        self.mode = mode
    }
}

// MARK: - Private Methods
private extension LoginService {
    func doesUserExist(username: String) -> Bool {
        let registeredUsers = defaultsStorage.registeredUsers
        return registeredUsers.contains(username)
    }
    
    func registerUser(_ userCredentials: UserCredentials) throws {
        do {
            try saveUserPassword(userCredentials: userCredentials)
            addToRegisteredUsers(userCredentials)
        } catch {
            throw error
        }
    }
    
    func isPasswordIsCorrect(_ userCredentials: UserCredentials) -> Bool {
        let correctPassword = keyChainService.read(key: userCredentials.username + "Pass")
        guard let correctPassword, correctPassword == userCredentials.password else  { return false }
        return true
    }
    
    func validateRegistrationCredeitials(_ userCredentials: UserCredentials) throws {
        do {
            try LoginService.validateRegistrationUsername(userCredentials.username)
            try LoginService.validateRegistrationPassword(userCredentials.password)
            guard !doesUserExist(username: userCredentials.username) else { throw LoginError.usernameTaken }
        } catch {
            throw error
        }
    }
    
    func saveUserPassword(userCredentials: UserCredentials) throws {
        let result = keyChainService.save(key: userCredentials.username + "Pass", value: userCredentials.password)
        switch result {
        case .failure(let error):
            throw error
        default:
            break
        }
    }
    
    func addToRegisteredUsers(_ userCredentials: UserCredentials) {
        var allUsers = defaultsStorage.registeredUsers
        allUsers.append(userCredentials.username)
        defaultsStorage.registeredUsers = allUsers
    }
    
    static func validateRegistrationUsername(_ username: String) throws {
        guard username.count <= DefaultValues.usernameMaxLength else { throw LoginError.invalidUsernameLengh }
        guard username.count >= DefaultValues.usernameMinLength else { throw LoginError.usernameIsTooShort }
        
        let usernameCharacters = CharacterSet(charactersIn: .usernameCharacters)
        let characterSet = CharacterSet(charactersIn: username)
        guard usernameCharacters.isSuperset(of: characterSet) else { throw LoginError.invalidUsernameCharacters }
    }
    
   static func validateRegistrationPassword(_ password: String) throws {
        guard password.count >= DefaultValues.passwordMinLength else { throw LoginError.passwordIsTooShort }
        
        let numbersSet = CharacterSet(charactersIn: .passwordNumbersCharacters)
        let uppercaseLettersSet = CharacterSet(charactersIn: .passwordUppercaseCharacters)
        guard password.rangeOfCharacter(from: numbersSet) != nil else { throw LoginError.invalidPasswordCharacters }
        guard password.rangeOfCharacter(from: uppercaseLettersSet) != nil  else { throw LoginError.invalidPasswordCharacters }
    }
}

// MARK: - Static Methods
extension LoginService {
    static func areCredentialsValid(credentials: UserCredentials, forMode mode: LoginServiceMode) throws -> Bool {
        switch mode {
        case .login:
            do {
                try LoginService.validateRegistrationUsername(credentials.username)
                guard credentials.password.count >= DefaultValues.passwordMinLength else { throw LoginError.passwordIsTooShort }
            } catch {
                throw error
            }
        case .register:
            do {
                try LoginService.validateRegistrationUsername(credentials.username)
                try LoginService.validateRegistrationPassword(credentials.password)
            } catch {
                throw error
            }
        }
        return true
    }
}

// MARK: - Constants
private extension LoginService {
    enum DefaultValues {
        static let usernameMaxLength = 32
        static let usernameMinLength = 6
        static let passwordMinLength = 8
    }
}

// MARK: - String Constants
private extension String {
    static let usernameCharacters = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    static let passwordNumbersCharacters = "1234567890"
    static let passwordUppercaseCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
}

// MARK: - LoginServiceMode
enum LoginServiceMode {
    case login
    case register
}

// MARK: - LoginError
enum LoginError: Error {
    case invalidUsernameCharacters
    case invalidUsernameLengh
    case usernameIsTooShort
    case invalidPasswordCharacters
    case invalidPasswordLengh
    case passwordIsTooShort
    case invalidCredentials
    case usernameTaken
    case userDoesNotExtist
}
