//
//  BeerCell.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 24/01/21.
//

import UIKit

final public class BeerCell: UITableViewCell {
    public let ibuLabel = UILabel()
    public let nameLabel = UILabel()
    public let imageContainer = UIView()
    public let beerImageView = UIImageView()
    
    private(set) public lazy var beerImageReturnButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
