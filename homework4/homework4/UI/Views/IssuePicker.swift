//
//  IssuePicker.swift
//  homework4
//
//  Created by Максим  on 31.05.2026.
//

import Foundation
import UIKit

protocol IssuePickerDelegate: AnyObject {
    func issueTapped(pickedIssues: Set<Issue>)
}

final class IssuePicker: UIView {
    private let botIssueButton: UIButton = {
        $0.setImage(UIImage(systemName: "square"), for: .normal)
        $0.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        $0.setTitle(Issue.botIssue.title, for: .normal)
        $0.setTitle(Issue.botIssue.title, for: .selected)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        return $0
    } (UIButton())
    
    private let sellerIssueButton: UIButton = {
        $0.setImage(UIImage(systemName: "square"), for: .normal)
        $0.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        $0.setTitle(Issue.p2pSellerIssue.title, for: .normal)
        $0.setTitle(Issue.p2pSellerIssue.title, for: .selected)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        return $0
    } (UIButton())
    
    private let walletIssueButton: UIButton = {
        $0.setImage(UIImage(systemName: "square"), for: .normal)
        $0.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        $0.setTitle(Issue.walletIssue.title, for: .normal)
        $0.setTitle(Issue.walletIssue.title, for: .selected)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        return $0
    } (UIButton())
    
    private let otherIssueButton: UIButton = {
        $0.setImage(UIImage(systemName: "square"), for: .normal)
        $0.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        $0.setTitle(Issue.other.title, for: .normal)
        $0.setTitle(Issue.other.title, for: .selected)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        return $0
    } (UIButton())
    
    private let upperHorisontalStack: UIStackView = {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .leading
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        return $0
    } (UIStackView())
    
    private let lowerHorisontalStack: UIStackView = {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .leading
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)

        return $0
    } (UIStackView())
    
    private let verticalStack: UIStackView = {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .leading
        $0.spacing = StackViewSpacing.extraSmall
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        return $0
    } (UIStackView())
   
    weak var delegate: IssuePickerDelegate?
    
    private var pickedIssues = Set<Issue>()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        addSubviews()
        setupUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        verticalStack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

// MARK: - Private Methods
private extension IssuePicker {
    func addSubviews() {
        addSubview(verticalStack)
        verticalStack.addArrangedSubview(upperHorisontalStack)
        verticalStack.addArrangedSubview(lowerHorisontalStack)
        
        upperHorisontalStack.addArrangedSubview(botIssueButton)
        upperHorisontalStack.addArrangedSubview(walletIssueButton)
        
        lowerHorisontalStack.addArrangedSubview(sellerIssueButton)
        lowerHorisontalStack.addArrangedSubview(otherIssueButton)
    }
    
    func setupUI() {
        setupButtons()
    }
    
    func setupButtons() {
        let buttons = [botIssueButton, sellerIssueButton, walletIssueButton, otherIssueButton]
        for button in buttons {
            button.addTarget(self, action: #selector(handleIssueButtonTap(sender:)), for: .touchUpInside)
        }
    }
    
    func setConstraints() {
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        upperHorisontalStack.translatesAutoresizingMaskIntoConstraints = false
        lowerHorisontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            upperHorisontalStack.topAnchor.constraint(equalTo: verticalStack.topAnchor),
            upperHorisontalStack.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor),
            upperHorisontalStack.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor),
            
            lowerHorisontalStack.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor),
            lowerHorisontalStack.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor),
            lowerHorisontalStack.bottomAnchor.constraint(equalTo: verticalStack.bottomAnchor)
        ])
        
        botIssueButton.translatesAutoresizingMaskIntoConstraints = false
        otherIssueButton.translatesAutoresizingMaskIntoConstraints = false
        sellerIssueButton.translatesAutoresizingMaskIntoConstraints = false
        walletIssueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            botIssueButton.topAnchor.constraint(equalTo: upperHorisontalStack.topAnchor),
            botIssueButton.bottomAnchor.constraint(equalTo: upperHorisontalStack.bottomAnchor),
            
            walletIssueButton.topAnchor.constraint(equalTo: upperHorisontalStack.topAnchor),
            walletIssueButton.bottomAnchor.constraint(equalTo: upperHorisontalStack.bottomAnchor),
            
            sellerIssueButton.topAnchor.constraint(equalTo: lowerHorisontalStack.topAnchor),
            sellerIssueButton.bottomAnchor.constraint(equalTo: lowerHorisontalStack.bottomAnchor),
            
            otherIssueButton.topAnchor.constraint(equalTo: lowerHorisontalStack.topAnchor),
            otherIssueButton.bottomAnchor.constraint(equalTo: lowerHorisontalStack.bottomAnchor)
        ])
    }
}

// MARK: - Action Handlers
private extension IssuePicker {
    @objc
    func handleIssueButtonTap(sender: UIButton) {
        var tappedIssue: Issue?
        
        switch sender {
        case botIssueButton:
            tappedIssue = .botIssue
        case walletIssueButton:
            tappedIssue = .walletIssue
        case sellerIssueButton:
            tappedIssue = .p2pSellerIssue
        case otherIssueButton:
            tappedIssue = .other
        default:
            break
        }
        
        guard let tappedIssue else { return }
        
        if pickedIssues.contains(tappedIssue) && sender.isSelected {
            pickedIssues.remove(tappedIssue)
            sender.isSelected = false
        } else if !pickedIssues.contains(tappedIssue) && !sender.isSelected {
            pickedIssues.insert(tappedIssue)
            sender.isSelected = true
        }
        
        delegate?.issueTapped(pickedIssues: pickedIssues)
    }
}
