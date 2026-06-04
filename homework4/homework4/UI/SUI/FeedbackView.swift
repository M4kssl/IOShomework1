//
//  FeedbackView.swift
//  homework4
//
//  Created by Максим  on 25.05.2026.
//

import Foundation
import SwiftUI

struct Feedback: View {
    @StateObject var feedbackService = FeedbackService()
    @State private var showPrivacyPolicy = false
    @FocusState private var focusedField: FocusedField?
    @State private var wasUsernameFocused = false
    @State private var wasFeedbackFocused = false
    @State private var hasVreificationBegun: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showFailureAlert: Bool = false
    
    let onDismiss: (() -> Void)?
    
    var body: some View {
        ZStack{
            Color(.systemYellow)
                .ignoresSafeArea()
            VStack {
                Text("Give us your feedback")
                    .font(.headline)
                usernameTextField
                feedbackLabel
                feedbackTextEditor
                issuePickerView
                termsAgreementCheckBox
                sendButton
            }
            .padding()
            if showPrivacyPolicy {
                privacyPolicyText
            }
            if hasVreificationBegun {
                let onFinish: () -> Void = {
                    handleVerificationResult()
                }
                HumanVerificationView(feedbackService: feedbackService, onFinish: onFinish)
            }
        }
        .alert("Sent successfully!", isPresented: $showSuccessAlert) {
           // Button()
        } message: {
            Text(FeedbackService.Texts.sentSuccessfully)
        }
        .alert("Validation failed!", isPresented: $showFailureAlert) {
           // Button()
        } message: {
            Text(FeedbackService.Texts.verificationFailure)
        }
    }
    
    var issuePickerView: some View {
        IssuePickerWrapper(issues: $feedbackService.issues)
    }
    
    var termsAgreementCheckBox: some View {
        HStack {
            Button(action: {
                feedbackService.isAgreementChecked.toggle()
            }) {
                Image(systemName: feedbackService.isAgreementChecked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(feedbackService.isAgreementChecked ? .blue : .gray)
            }
            Text("I agree to")
            Button("the privacy policy") {
                showPrivacyPolicy = true
            }
            .buttonStyle(.plain)
            .foregroundColor(.blue)
            .underline()
        }
    }
    
    var privacyPolicyText: some View {
        VStack {
            Text("Privacy policy")
                .font(.title)
                .padding()
            ScrollView {
                Text(FeedbackService.Texts.policyText)
                    .padding()
            }
            Button("Close") {
                showPrivacyPolicy = false
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(CornerRadius.small)
            .padding()
        }
        .frame(width: 300, height: 500)
        .background(Color.white)
        .cornerRadius(CornerRadius.standard)
        .shadow(radius: 20)
    }
    
    var sendButton: some View {
        Button(action: {
            feedbackService.beginVerification()
            hasVreificationBegun.toggle()
        }) {
            Text("Send")
                .foregroundColor(!feedbackService.isFeedbackValid
                                 || !feedbackService.isUsernameValid
                                 || !feedbackService.isAgreementChecked
                                 || !wasFeedbackFocused
                                 || !wasUsernameFocused ? .gray : .white)
        }
        .padding()
        .disabled(!feedbackService.isFeedbackValid
                  || !feedbackService.isUsernameValid
                  || !feedbackService.isAgreementChecked
                  || !wasFeedbackFocused
                  || !wasUsernameFocused)
        .background(.blue)
        .cornerRadius(CornerRadius.small)
    }
    
    var usernameTextField: some View {
        VStack {
            TextField("Username", text: $feedbackService.username)
                .textFieldStyle(.roundedBorder)
                .background(.white)
                .focused($focusedField, equals: .username)
                .onChange(of: focusedField) { [self] newValue in
                    if newValue != .username {
                        feedbackService.validateUsername()
                    } else if newValue == .username {
                        self.wasUsernameFocused = true
                    }
                }
            if focusedField != .username && !feedbackService.isUsernameValid && wasUsernameFocused {
                Text(FeedbackService.Texts.usernameValidationError)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
    }
    
    var feedbackLabel: some View {
        Text("Feedback:")
            .frame( maxWidth: .infinity, alignment: .leading)
    }
    
    var feedbackTextEditor: some View {
        VStack {
            TextEditor(text: $feedbackService.feedback)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(.white)
                .focused($focusedField, equals: .feedback)
                .onChange(of: focusedField) { newValue in
                    if newValue != .feedback {
                        feedbackService.validateFeedback()
                    } else if newValue == .feedback {
                        wasFeedbackFocused = true
                    }
                }
            if focusedField != .feedback && !feedbackService.isFeedbackValid && wasFeedbackFocused {
                Text(FeedbackService.Texts.feedbackValidationError)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
    }
}

extension Feedback {
    func handleVerificationResult() {
        hasVreificationBegun.toggle()
        if feedbackService.isLastGestureValid {
            showSuccessAlert.toggle()
            feedbackService.sendFeedback()
            feedbackService.clearUserInputs()
        } else {
            showFailureAlert.toggle()
        }
    }
}

private extension Feedback {
    enum FocusedField {
        case username
        case feedback
    }
}
