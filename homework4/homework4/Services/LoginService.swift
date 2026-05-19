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
        AppLogger.login.info("login service init")
        mode = initialMode
    }
    
    func previouslyLoggedUser() -> String? {
        AppLogger.login.info("previously logged user requested")
        return defaultsStorage.loggedUser
    }
    
    func tryLogUserIn(userCredentials: UserCredentials) throws {
        AppLogger.login.info("login attempt started, mode set to \(self.mode.rawValue)")
        switch mode {
        case .login:
            do {
                guard doesUserExist(username: userCredentials.username) else { throw LoginError.userDoesNotExtist }
                guard isPasswordIsCorrect(userCredentials) else { throw LoginError.invalidCredentials }
            } catch {
                AppLogger.login.error("login attempt finished with error, inputted credentials: username - \(userCredentials.username), password - \(userCredentials.password), error: \(error)")
                throw error
            }
        case .register:
            do {
                try validateRegistrationCredeitials(userCredentials)
                try registerUser(userCredentials)
            } catch {
                AppLogger.login.error("login attempt finished with error, inputted credentials: username - \(userCredentials.username), password - \(userCredentials.password), error: \(error)")
                throw error
            }
        }
        AppLogger.login.info("login attempt finished successfully, logged user \(userCredentials.username)")
        defaultsStorage.loggedUser = userCredentials.username
    }
    
    func changeMode(to mode: LoginServiceMode) {
        self.mode = mode
        AppLogger.login.info("mode set to \(self.mode.rawValue)")
    }
}

// MARK: - Private Methods
private extension LoginService {
    func doesUserExist(username: String) -> Bool {
        AppLogger.login.info("checking if user \(username) exists")
        let registeredUsers = defaultsStorage.registeredUsers
        return registeredUsers.contains(username)
    }
    
    func registerUser(_ userCredentials: UserCredentials) throws {
        AppLogger.login.info("registration attempt for user: \(userCredentials.username)")
        do {
            try saveUserPassword(userCredentials: userCredentials)
            addToRegisteredUsers(userCredentials)
        } catch {
            AppLogger.login.error("registration failure for user: \(userCredentials.username), error: \(error)")
            throw error
        }
        AppLogger.login.info("registration success for user: \(userCredentials.username)")
    }
    
    func isPasswordIsCorrect(_ userCredentials: UserCredentials) -> Bool {
        AppLogger.login.info("checking if password is correct for user: \(userCredentials.username)")
        let correctPassword = keyChainService.read(key: userCredentials.username + "Pass")
        guard let correctPassword, correctPassword == userCredentials.password else  { return false }
        return true
    }
    
    func validateRegistrationCredeitials(_ userCredentials: UserCredentials) throws {
        AppLogger.login.info("credenital validation attempt for user: \(userCredentials.username)")
        do {
            try LoginService.validateRegistrationUsername(userCredentials.username)
            try LoginService.validateRegistrationPassword(userCredentials.password)
            guard !doesUserExist(username: userCredentials.username) else { throw LoginError.usernameTaken }
        } catch {
            AppLogger.login.error("credenital validation failure for user: \(userCredentials.username), error: \(error)")
            throw error
        }
        AppLogger.login.info("credenital validation success for user: \(userCredentials.username)")

    }
    
    func saveUserPassword(userCredentials: UserCredentials) throws {
        AppLogger.login.info("password saving attempt for user: \(userCredentials.username)")
        let result = keyChainService.save(key: userCredentials.username + "Pass", value: userCredentials.password)
        switch result {
        case .failure(let error):
            AppLogger.login.info("password saving failure for user: \(userCredentials.username), error: \(error)")
            throw error
        default:
            break
        }
        AppLogger.login.info("password saving success for user: \(userCredentials.username)")
    }
    
    func addToRegisteredUsers(_ userCredentials: UserCredentials) {
        var allUsers = defaultsStorage.registeredUsers
        allUsers.append(userCredentials.username)
        defaultsStorage.registeredUsers = allUsers
    }
    
    static func validateRegistrationUsername(_ username: String) throws {
        AppLogger.login.info("validating username for registration, username: \(username)")
        guard username.count <= DefaultValues.usernameMaxLength else { throw LoginError.invalidUsernameLengh }
        guard username.count >= DefaultValues.usernameMinLength else { throw LoginError.usernameIsTooShort }
        
        let usernameCharacters = CharacterSet(charactersIn: .usernameCharacters)
        let characterSet = CharacterSet(charactersIn: username)
        guard usernameCharacters.isSuperset(of: characterSet) else { throw LoginError.invalidUsernameCharacters }
    }
    
   static func validateRegistrationPassword(_ password: String) throws {
        AppLogger.login.info("validationg password for registration")
        guard password.count >= DefaultValues.passwordMinLength else {
            AppLogger.login.warning("password is too short")
            throw LoginError.passwordIsTooShort
        }
        
        let numbersSet = CharacterSet(charactersIn: .passwordNumbersCharacters)
        let uppercaseLettersSet = CharacterSet(charactersIn: .passwordUppercaseCharacters)
        guard password.rangeOfCharacter(from: numbersSet) != nil else { throw LoginError.invalidPasswordCharacters }
        guard password.rangeOfCharacter(from: uppercaseLettersSet) != nil  else { throw LoginError.invalidPasswordCharacters }
    }
}

// MARK: - Static Methods
extension LoginService {
    static func areCredentialsValid(credentials: UserCredentials, forMode mode: LoginServiceMode) throws -> Bool {
        AppLogger.login.debug("checking if credentials are valid for user \(credentials.username), mode: \(mode.rawValue)")
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
        AppLogger.login.debug("validation success for user \(credentials.username), mode: \(mode.rawValue)")
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
enum LoginServiceMode: String {
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
