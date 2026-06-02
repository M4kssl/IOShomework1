//
//  FeedbackService.swift
//  homework4
//
//  Created by Максим  on 25.05.2026.
//

import Foundation

protocol FeedbackServiceProtocol {
    var username: String { get set }
    var feedback: String { get set }
    var isAgreementChecked: Bool { get set }
    var isUsernameValid: Bool { get set }
    var isFeedbackValid: Bool { get set }
    var issues: Set<Issue> { get set }
    
    func sendFeedback()
    func validateUsername()
    func validateFeedback()
}

// Коммент про диалог про использование viewModel с wrapper'ом @StateObject + ObservableObject без combine
final class FeedbackService: FeedbackServiceProtocol, ObservableObject {
    @Published var username = ""
    @Published var feedback = ""
    @Published var isAgreementChecked = false
    @Published var isUsernameValid = true
    @Published var isFeedbackValid = true
    @Published var issues = Set<Issue>()
    
    func sendFeedback() {
        AppLogger.login.info("Feedback sent")
    }
    
    func validateUsername() {
        let usernameWithNoSpaces = username.replacingOccurrences(of: " ", with: "")
        isUsernameValid = usernameWithNoSpaces.count >= 3 && usernameWithNoSpaces.count <= 30 && username.count <= 30
    }
    
    func validateFeedback() {
        isFeedbackValid = feedback.count >= 3 && feedback.count <= 150
    }
}

extension FeedbackService {
    enum Texts {
        static let usernameValidationError = "Username must be 3-30 characters long"
        static let feedbackValidationError = "Feedback must be 3-150 characters long"
        
        static let policyText =
                """
                Privacy Policy for Currency Exchange App

                Effective date: May 26, 2026

                This Privacy Policy explains how the Currency Exchange App (“we,” “our,” or “us”) collects, uses, stores, and protects information when you use our application.

                By using the app, you agree to the collection and use of information in accordance with this Privacy Policy.

                1. Information We Collect

                We aim to collect only the minimum information necessary to provide and improve the app.

                We may collect:

                - Device information, such as device model, operating system version, and app version.
                - Usage data, such as feature interactions, app performance, and error reports.
                - Approximate location, if you choose to allow access, for displaying relevant exchange rates by region, where applicable.
                - Technical data, such as IP address, time zone, language preferences, and diagnostic logs.
                - Personal data you voluntarily provide, such as if you contact us by email or submit feedback.

                We do not intentionally collect sensitive personal data unless you provide it voluntarily and it is necessary for support purposes.

                2. How We Use Information

                We use collected information to:

                - Provide and operate the app.
                - Display exchange rates and related financial information.
                - Improve app performance, stability, and user experience.
                - Diagnose and fix technical issues.
                - Respond to support requests and user feedback.
                - Maintain security and prevent misuse.

                3. Legal Basis for Processing

                Where required by law, we process personal data based on one or more of the following legal grounds:

                - Your consent.
                - Performance of a contract or pre-contractual measures.
                - Our legitimate interests in operating and improving the app.
                - Compliance with legal obligations.

                4. Data Storage and Retention

                We retain personal data only for as long as necessary to fulfill the purposes described in this Policy, unless a longer retention period is required by law.

                When data is no longer needed, we delete it or anonymize it in a secure manner.

                5. Data Sharing

                We do not sell your personal data.

                We may share information only with:

                - Service providers that help us operate the app, such as hosting, analytics, or error-monitoring services.
                - Authorities or regulators, if required by law or legal process.
                - Third parties with your consent, if needed for a specific feature or service.

                Any third-party service providers are expected to handle data in accordance with applicable privacy obligations.

                6. Analytics and Crash Reports

                We may use analytics and crash-reporting tools to understand how the app is used and to improve its reliability.

                These tools may collect technical and usage data, but we try to configure them to minimize personal data collection whenever possible.

                7. Cookies and Similar Technologies

                If the app uses web-based components, we may use cookies or similar technologies to improve functionality, remember preferences, or analyze usage.

                You can control cookies through your device or browser settings, where applicable.

                8. Data Security

                We use reasonable technical and organizational measures to protect personal data against unauthorized access, loss, misuse, or alteration.

                However, no method of transmission over the internet or electronic storage is completely secure, so we cannot guarantee absolute security.

                9. Your Rights

                Depending on your location, you may have rights regarding your personal data, such as:

                - The right to access your data.
                - The right to correct inaccurate data.
                - The right to delete your data.
                - The right to restrict or object to processing.
                - The right to withdraw consent.
                - The right to data portability, where applicable.

                To exercise these rights, contact us using the details below.

                10. Children’s Privacy

                Our app is not intended for children under the age of 13, or under the minimum age required by applicable law.

                We do not knowingly collect personal data from children. If you believe a child has provided personal data, please contact us so we can remove it.

                11. International Data Transfers

                If your information is transferred to servers or service providers in other countries, we take appropriate steps to protect it in accordance with applicable laws.

                12. Third-Party Links

                The app may contain links to third-party websites or services. We are not responsible for the privacy practices of those third parties.

                We encourage you to review their privacy policies before using their services.

                13. Changes to This Policy

                We may update this Privacy Policy from time to time.

                If we make material changes, we will notify users by updating the effective date or by providing notice in the app.
               """
    }
}

enum Issue: Int, CaseIterable {
    case botIssue
    case p2pSellerIssue
    case walletIssue
    case other
    
    var title: String {
        switch self {
        case .botIssue:
            return "Issue with bot"
        case .p2pSellerIssue:
            return "Seller doesn't reply"
        case .walletIssue:
            return "Issue with balance"
        case .other:
            return "Other issue"
        }
    }
}
