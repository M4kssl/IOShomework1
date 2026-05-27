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
    
    let onDismiss: (() -> Void)?
    
    var body: some View {
        ZStack{
            Color(.systemYellow)
                .ignoresSafeArea()
            VStack {
                Text("Give us your feedback")
                    .font(.headline)
                TextField("Username", text: $feedbackService.username)
                    .textFieldStyle(.roundedBorder)
                    .background(.white)
                Text("Feedback:")
                    .frame( maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $feedbackService.feedback)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .background(.white)
                termsAgreementCheckBox
                Button(action: {
                    feedbackService.sendFeedback()
                    onDismiss?()
                }) {
                    Text("Send")
                        .foregroundColor(feedbackService.username.isEmpty || feedbackService.feedback.isEmpty || !feedbackService.isAgreementChecked ? .gray : .white)
                }
                .padding()
                .disabled(feedbackService.username.isEmpty || feedbackService.feedback.isEmpty || !feedbackService.isAgreementChecked)
                .background(.blue)
                .cornerRadius(CornerRadius.small)
            }
            .padding()
            if showPrivacyPolicy {
                privacyPolicyText
            }
        }
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
                Text(feedbackService.policyText)
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
        .transition(.scale)
        .animation(.default, value: showPrivacyPolicy)
    }
}
