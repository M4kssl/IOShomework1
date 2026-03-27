//
//  SupportInformationView.swift
//  homework4
//
//  Created by Максим  on 23.03.2026.
//
import Foundation
import UIKit

final class SupportInformationView: UIView {
    private let stackView = UIStackView()
    private let informationLabel = UILabel()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods
private extension SupportInformationView {
    func setupUI() {
        addStackview()
        addTextInformation()
        addImage()
        setConstraints()
    }
        
    func addStackview() {
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
    }
    
    func addImage() {
        imageView.image = UIImage(named: defaultTexts.imageName)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageView)
    }
    
    func addTextInformation() {
        informationLabel.text = defaultTexts.informationText
        informationLabel.numberOfLines = 3
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(informationLabel)
    }
    
    func setConstraints() {
        setImageConstraints()
        setLabelConstraints()
        setStackViewConstraints()
    }
    
    func setImageConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 150),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 150)
          ])
    }
    
    func setLabelConstraints() {
        NSLayoutConstraint.activate([
            informationLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            informationLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 100)
        ])
    }
    
    func setStackViewConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
          ])
    }
}

// MARK: - Constants
private extension SupportInformationView {
    struct defaultTexts {
        static let informationText = "You can call our customer support:\n +123456789"
        static let imageName = "phone"
    }
}
