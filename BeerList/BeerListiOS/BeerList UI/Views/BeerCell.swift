//
//  BeerCell.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 24/01/21.
//

import UIKit

final public class BeerCell: UITableViewCell {
    @IBOutlet private(set) public var ibuLabel: UILabel!
    @IBOutlet private(set) public var nameLabel: UILabel!
    @IBOutlet private(set) public var imageContainer: UIView!
    @IBOutlet private(set) public var beerImageView: UIImageView!
    @IBOutlet private(set) public var beerImageReturnButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
