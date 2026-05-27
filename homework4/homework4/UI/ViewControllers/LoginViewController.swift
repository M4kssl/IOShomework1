//
//  LoginViewController.swift
//  homework4
//
//  Created by Максим  on 28.04.2026.
//

import Foundation
import UIKit
import Combine

final class LoginViewController: UIViewController {
    private var loginService = LoginService(initialMode: .login)
    private var cancellables = Set<AnyCancellable>()
    
    var onLoginSuccess: (() -> Void)?
    var onCantLogInTapped: (() -> Void)?
    
    @Published var currentUsernameText: String = ""
    @Published var currentPasswordText: String = ""
    @Published var currentMode: LoginServiceMode = .login
    
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let modeStackView: UIStackView = {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = StackViewSpacing.standard
        return $0
    } (UIStackView())
    
    private let loginModeButton: UIButton = {
        $0.setTitle("Login", for: .normal)
        $0.layer.borderWidth = BorderWidth.thin
        $0.layer.cornerRadius = CornerRadius.small
        $0.backgroundColor = .white
        $0.setTitleColor(.systemBlue, for: .selected)
        $0.setTitleColor(.black, for: .normal)
        return $0
    } (UIButton())
    
    private let registerModeButton: UIButton = {
        $0.setTitle("Register", for: .normal)
        $0.layer.borderWidth = BorderWidth.thin
        $0.layer.cornerRadius = CornerRadius.small
        $0.backgroundColor = .white
        $0.setTitleColor(.systemBlue, for: .selected)
        $0.setTitleColor(.black, for: .normal)
        return $0
    } (UIButton())
    
    private let cantLogInButton: UIButton = {
        $0.setTitle("Can't log in", for: .normal)
        $0.layer.borderWidth = BorderWidth.thin
        $0.layer.cornerRadius = CornerRadius.small
        $0.backgroundColor = .white
        $0.setTitleColor(.systemBlue, for: .selected)
        $0.setTitleColor(.black, for: .normal)
        return $0
    } (UIButton())
    
    private let proceedButton: UIButton = {
        $0.layer.backgroundColor = UIColor.systemBlue.cgColor
        $0.layer.borderWidth = BorderWidth.standard
        $0.layer.cornerRadius = CornerRadius.small
        $0.setTitle(.proceedButton, for: .normal)
        $0.setTitleColor(UIColor.lightGray, for: .disabled)
        return $0
    } (UIButton())
    
    private let warningLabel: UILabel = {
        $0.font = AppFonts.footnote
        $0.numberOfLines = .zero
        $0.textColor = .systemRed
        $0.isHidden = true
        return $0
    } (UILabel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupUI()
        setConstraints()
        updateViewFromModel()
        setupBindings()
    }
}

// MARK: - UI Methods
private extension LoginViewController {
    func updateViewFromModel() {
        switch loginService.mode {
        case .login:
            updateModeButtonsState(lastTappedButton: loginModeButton)
        case .register:
            updateModeButtonsState(lastTappedButton: registerModeButton)
        }
    }
    
    func addSubviews() {
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(warningLabel)
        view.addSubview(proceedButton)
        view.addSubview(cantLogInButton)
        
        view.addSubview(modeStackView)
        modeStackView.addArrangedSubview(loginModeButton)
        modeStackView.addArrangedSubview(registerModeButton)
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.systemYellow
        
        setupProceedButton()
        setupLoginModeButton()
        setupRegisterModeButton()
        setupUsernameTextField()
        setupPasswordTextField()
        setupCantLogInButton()
    }
    
    func setupProceedButton() {
        proceedButton.addTarget(self, action: #selector(handleProceedButtonTap), for: .touchUpInside)
    }
    
    func setupLoginModeButton() {
        loginModeButton.addTarget(self, action: #selector(handleModeButtonTap), for: .touchUpInside)
    }
    
    func setupRegisterModeButton() {
        registerModeButton.addTarget(self, action: #selector(handleModeButtonTap), for: .touchUpInside)
    }
    
    func setupCantLogInButton() {
        cantLogInButton.addTarget(self, action: #selector(handleCantLogInTap), for: .touchUpInside)
    }
    
    func setConstraints() {
        setUsernameTextViewConstraints()
        setPasswordTextViewConstraints()
        setWarningLabelConstraints()
        setProceedButtonConstraints()
        setModeStackViewConstraints()
        setCantLogInButtonConstraints()
    }
    
    func setupUsernameTextField() {
        usernameTextField.placeholder = .usernamePlaceholder
        usernameTextField.font = AppFonts.body
        usernameTextField.layer.cornerRadius = CornerRadius.small
        usernameTextField.layer.backgroundColor = UIColor.white.cgColor
        usernameTextField.layer.borderWidth = BorderWidth.standard
    }
    
    func setupPasswordTextField() {
        passwordTextField.placeholder = .passwordPlaceholder
        passwordTextField.font = AppFonts.body
        passwordTextField.textContentType = .password
        passwordTextField.layer.cornerRadius = CornerRadius.small
        passwordTextField.layer.backgroundColor = UIColor.white.cgColor
        passwordTextField.layer.borderWidth = BorderWidth.standard
        passwordTextField.isSecureTextEntry = true
    }
    
    func setUsernameTextViewConstraints() {
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -ConstraintSpacing.extraLarge),
            usernameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.large),
            usernameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.large)
        ])
    }
    
    func setPasswordTextViewConstraints() {
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: ConstraintSpacing.standard),
            passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.large),
            passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.large)
        ])
    }
    
    func setWarningLabelConstraints() {
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            warningLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: ConstraintSpacing.standard),
            warningLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.large),
            warningLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.large)
        ])
    }
    
    func setProceedButtonConstraints() {
        proceedButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            proceedButton.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: ConstraintSpacing.standard),
            proceedButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.large),
            proceedButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.large)
        ])
    }
    
    func setModeStackViewConstraints() {
        modeStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            modeStackView.topAnchor.constraint(equalTo: proceedButton.bottomAnchor, constant: ConstraintSpacing.standard),
            modeStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.large),
            modeStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.large)
        ])
    }
    
    func setCantLogInButtonConstraints() {
        cantLogInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cantLogInButton.topAnchor.constraint(equalTo: modeStackView.bottomAnchor, constant: ConstraintSpacing.standard),
            cantLogInButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.large),
            cantLogInButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.large)
        ])
    }
    
    func changeUsernameLenghWarningVisibility(isMaxLengthExeeded: Bool) {
        warningLabel.isHidden = !isMaxLengthExeeded
    }
    
    func updateModeButtonsState(lastTappedButton: UIButton) {
        loginModeButton.isSelected = lastTappedButton == loginModeButton
        registerModeButton.isSelected = lastTappedButton == registerModeButton
    }
    
    func handleLoginError(_ error: Error) {
        var text: String
        
        switch error {
        case LoginError.invalidUsernameCharacters:
            text = .usernameCharactersWarning
        case LoginError.invalidPasswordLengh:
            text = .passwordLengthWarning
        case LoginError.invalidPasswordCharacters:
            text = .passwordCharactersWarning
        case LoginError.invalidUsernameLengh:
            text = .usernameLengthWarning
        case LoginError.passwordIsTooShort:
            text = .passwordLengthWarning
        case LoginError.usernameIsTooShort:
            text = .usernameIsShort
        case LoginError.usernameTaken:
            text = .usernameTakenWarning
        case LoginError.userDoesNotExtist:
            text = .invalidCredentialsWarning
        case LoginError.invalidCredentials:
            text = .invalidCredentialsWarning
        default:
            text = .somethingWentWrong
        }
        warningLabel.text = text
        warningLabel.isHidden = false
    }
}

// MARK: - Action Handlers
private extension LoginViewController {
    @objc
    func handleProceedButtonTap() {
        do {
            guard let username = usernameTextField.text else { throw LoginError.usernameIsTooShort }
            guard let password = passwordTextField.text else { throw LoginError.passwordIsTooShort }
            let userCredentials = UserCredentials(username: username, password: password)
            try loginService.tryLogUserIn(userCredentials: userCredentials)
            SessionManager.shared.beginSession(username: userCredentials.username)
            onLoginSuccess?()
        } catch {
            handleLoginError(error)
        }
    }
    
    @objc
    func handleModeButtonTap(_ sender: UIButton) {
        if sender == loginModeButton {
            loginService.changeMode(to: .login)
        } else {
            loginService.changeMode(to: .register)
        }
        currentMode = loginService.mode
        updateModeButtonsState(lastTappedButton: sender)
    }
    
    @objc
    func handleCantLogInTap() {
        onCantLogInTapped?()
    }
}

// MARK: - Bindings
private extension LoginViewController {
    func setupBindings() {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: usernameTextField)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .sink { [weak self] text in
                self?.currentUsernameText = text
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: passwordTextField)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .sink { [weak self] text in
                self?.currentPasswordText = text
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3($currentUsernameText, $currentPasswordText, $currentMode)
            .map { username, password, mode -> Bool in
                   let credentials = UserCredentials(username: username, password: password)
                   return (try? LoginService.areCredentialsValid(credentials: credentials, forMode: mode)) ?? false
               }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: proceedButton)
            .store(in: &cancellables)
    }
}

// MARK: - Routing
private extension LoginViewController {
    func routeToMainScreen() {
        let market = Market(amountOfCurrencies: 5)
        let marketCurrencies = market.getCurrenciesSnapshot()
        let marketCurrenciesArray = market.getArrayOfCurrencies()
        let botViewController = BotViewController(marketCurrencies: marketCurrencies)
        let tradingViewController = TradingViewController(localCurrencies: marketCurrenciesArray)
        let settingsViewController = SettingsViewController()
        let tabBarController = UITabBarController()
        
        botViewController.tabBarItem = UITabBarItem(
            title: "Bot",
            image: UIImage(systemName: "brain")
            , tag: 0
        )
        botViewController.title = "Bot"
        
        let tradingNavigationController = UINavigationController()
        let tradingCoordinator = TradingCoordinator(navigationController: tradingNavigationController)
        tradingCoordinator.start()
        
        settingsViewController.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear")
            , tag: 3
        )
        settingsViewController.title = "Settings"
        
        let botNavigationController = UINavigationController(rootViewController: botViewController)
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        tabBarController.viewControllers = [botNavigationController, tradingNavigationController, settingsNavigationController]
        navigationController?.replaceRootViewController(with: tabBarController)
    }
}

// MARK: - String Constants
private extension String {
    static let usernameCharactersWarning = "Username must contain only following characters: 0-9, a-z, A-Z and _"
    static let usernameLengthWarning = "Username must not be longer than 32 characters"
    static let usernameIsShort = "Username must be at least 6 characters long"
    static let passwordLengthWarning = "Password must be at leas 8 characters long"
    static let passwordCharactersWarning = "Password must contain at least one number and uppercase letter"
    static let usernameTakenWarning = "Username has already been taken"
    static let somethingWentWrong = "Oops... Something went wrong"
    static let invalidCredentialsWarning = "Wrong username or password"
    static let registerButton = "Register"
    static let logInButton = "Log in"
    static let usernamePlaceholder = "Username"
    static let passwordPlaceholder = "Password"
    static let proceedButton = "Proceed"
}
