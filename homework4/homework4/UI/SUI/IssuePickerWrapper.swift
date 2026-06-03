//
//  IssuePickerWrapper.swift
//  homework4
//
//  Created by Максим  on 31.05.2026.
//

import Foundation
import SwiftUI

struct IssuePickerWrapper: UIViewRepresentable {
    @Binding var pickedIssues: Set<Issue>
        
    init(issues: Binding<Set<Issue>>) {
        self._pickedIssues = issues
    }
    
    func makeCoordinator() -> IssuePickerWrapperCoordinator {
        IssuePickerWrapperCoordinator(issues: $pickedIssues)
    }
   
    func makeUIView(context: Context) -> some UIView {
        let issuePicker = IssuePicker()
        issuePicker.delegate = context.coordinator
        issuePicker.setContentHuggingPriority(.required, for: .vertical)
        issuePicker.setContentCompressionResistancePriority(.required, for: .vertical)
        return issuePicker
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // No update implementation needed
    }
    
    final class IssuePickerWrapperCoordinator: IssuePickerDelegate {
        @Binding var pickedIssues: Set<Issue>
        
        init(issues: Binding<Set<Issue>>) {
            self._pickedIssues = issues
        }
        
        func issueTapped(pickedIssues: Set<Issue>) {
            self.pickedIssues = pickedIssues
        }
    }
}
