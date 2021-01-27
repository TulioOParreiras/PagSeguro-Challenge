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
    public let imageContainer = UIView()
    public let imageView = UIImageView()
    public let taglineLabel = UILabel()
    public let abvLabel = UILabel()
    public let ibuLabel = UILabel()
    public let descriptionLabel = UILabel()
    
    private(set) public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var delegate: BeerDetailsViewControllerDelegate?
    
    public convenience init(delegate: BeerDetailsViewControllerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
    }
    
    public func display(_ model: BeerDetailsViewModel<UIImage>) {
        self.title = model.name
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
    
    @objc func retryButtonTapped() {
        loadImage()
    }
}
