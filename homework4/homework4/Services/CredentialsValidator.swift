//
//  CredentialsValidator.swift
//  homework4
//
//  Created by Максим  on 28.04.2026.
//

import Foundation

protocol CredentialsValidatorProtocol {
    func validatePasswordRegistration() throws
    func validateUsernameRegistration() throws
}
