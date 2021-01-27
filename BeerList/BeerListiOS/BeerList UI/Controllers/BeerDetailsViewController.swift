//
//  BeerDetailsViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 26/01/21.
//

import UIKit
import BeerList

public protocol BeerDetailsViewControllerDelegate {
    func didRequestBeerImageLoad()
}

public final class BeerDetailsViewController: UIViewController, BeerDetailsView {
    @IBOutlet private(set) public var imageContainer: UIView!
    @IBOutlet private(set) public var imageView: UIImageView!
    @IBOutlet private(set) public var nameLabel: UILabel!
    @IBOutlet private(set) public var taglineLabel: UILabel!
    @IBOutlet private(set) public var abvLabel: UILabel!
    @IBOutlet private(set) public var ibuLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var retryButton: UIButton!
    
    public var delegate: BeerDetailsViewControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
    }
    
    public func display(_ model: BeerDetailsViewModel<UIImage>) {
        self.nameLabel.text = model.name
        self.taglineLabel.text = model.tagline
        self.abvLabel.text = model.abv
        self.ibuLabel.text = model.ibu
        self.descriptionLabel.text = model.description
        self.ibuLabel.isHidden = model.ibu == nil
        self.retryButton.isHidden = !model.shouldRetry
        self.imageView.setImageAnimated(model.image)
        self.imageContainer.isShimmering = model.isLoading
    }
    
    func loadImage() {
        delegate?.didRequestBeerImageLoad()
    }
    
    @IBAction private func retryButtonTapped() {
        loadImage()
    }
}
