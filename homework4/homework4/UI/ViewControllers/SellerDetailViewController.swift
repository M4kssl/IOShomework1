//
//  SellerDetailViewController.swift
//  homework4
//
//  Created by Максим  on 08.05.2026.
//

import Foundation
import UIKit

final class SellerDetailViewController: UIViewController {
    private let sellerDetailModel = SellerDetailViewModel()
    
    private let detailStackView: UIStackView = {
        $0.axis = .vertical
        $0.spacing = ConstraintSpacing.standard
        $0.distribution = .fillEqually
        return $0
    } (UIStackView())
    
    private let nameLabel: UILabel = {
        $0.font = AppFonts.headline
        $0.numberOfLines = .zero
        return $0
    } (UILabel())
   
    private let idLabel: UILabel = {
        $0.font = AppFonts.headline
        $0.numberOfLines = .zero
        return $0
    } (UILabel())
   
    private let ratingLabel: UILabel = {
        $0.font = AppFonts.headline
        $0.numberOfLines = .zero
        return $0
    } (UILabel())
   
    private let dealsLabel: UILabel = {
        $0.font = AppFonts.headline
        $0.numberOfLines = .zero
        return $0
    } (UILabel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupUI()
        setConstraints()
        updateViewFromModel()
    }
}

private extension SellerDetailViewController {
    func addSubviews() {
        view.addSubview(detailStackView)
        
        detailStackView.addArrangedSubview(nameLabel)
        detailStackView.addArrangedSubview(idLabel)
        detailStackView.addArrangedSubview(ratingLabel)
        detailStackView.addArrangedSubview(dealsLabel)
    }
    
    func setupUI() {
        view.backgroundColor = .systemYellow
    }
    
    func setConstraints() {
        setDetailStackViewConstraints()
    }
    
    func updateViewFromModel() {
        nameLabel.text = "Name: " + sellerDetailModel.sellerDetail.name
        idLabel.text = "ID: " + sellerDetailModel.sellerDetail.id.uuidString
        ratingLabel.text = "Rating: " + sellerDetailModel.sellerDetail.rating.stringWithTwoDecimalPlaces
        dealsLabel.text = "Completed deals: \(sellerDetailModel.sellerDetail.completedDeals)"
    }
    
    func setDetailStackViewConstraints() {
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ConstraintSpacing.large),
            detailStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintSpacing.large),
            detailStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintSpacing.standard),
            detailStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintSpacing.standard)
        ])
    }
}
