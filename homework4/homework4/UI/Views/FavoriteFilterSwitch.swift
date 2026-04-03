//
//  FavoriteFilterSwitch.swift
//  homework4
//
//  Created by Максим  on 02.04.2026.
//

import Foundation
import UIKit

protocol FavoriteFilterSwitchDelegate: AnyObject {
    func switchFilter(isFilterOn: Bool)
}

final class FavoriteFilterSwitch: UIView {
    private let stackView = UIStackView()
    private let filterLabel = UILabel()
    private let filterSwitch = UISwitch()
    private let filterLabelText = "Show only favorite"

    
    weak var delegate: FavoriteFilterSwitchDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        addSubviews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FavoriteFilterSwitch {
    func addSubviews() {
        stackView.addArrangedSubview(filterLabel)
        stackView.addArrangedSubview(filterSwitch)
        addSubview(stackView)
    }
    
    func setupUI() {
        setupStackView()
        setupFilterLabel()
        setupFilterSwitch()
    }
    
    func setupStackView() {
        stackView.axis = .horizontal
        stackView.spacing = StackViewSpacing.standard
    }
    
    func setupFilterLabel() {
        filterLabel.font = AppFonts.title
        filterLabel.text = filterLabelText
        filterLabel.textAlignment = .right
        filterLabel.sizeToFit()
    }
    
    func setupFilterSwitch() {
        filterSwitch.addTarget(self, action: #selector(handleFilterSwitchValueChange), for: .valueChanged)
    }
    
    func setConstraints() {
        setStackViewConstraints()
    }
    
    func setStackViewConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
          ])
    }
    
    @objc
    func handleFilterSwitchValueChange() {
        delegate?.switchFilter(isFilterOn: filterSwitch.isOn)
    }
}
