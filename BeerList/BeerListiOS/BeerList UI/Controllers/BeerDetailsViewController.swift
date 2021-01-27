//
//  BeerDetailsViewController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 26/01/21.
//

import UIKit
import BeerList

public final class BeerDetailsViewController: UIViewController {
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
    
    private var imageLoader: BeerImageDataLoader?
    private var model: Beer!
    private var task: BeerImageDataLoaderTask?
    
    public convenience init(model: Beer, imageLoader: BeerImageDataLoader) {
        self.init()
        self.model = model
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = model.name
        display(model: model)
    }
    
    deinit {
        task?.cancel()
    }
    
    func loadImage() {
        retryButton.isHidden = true
        imageContainer.isShimmering = true
        task = imageLoader?.loadImageData(from: model.imageURL) { [weak self] result in
            guard let self = self else { return }
            self.imageContainer.isShimmering = false
            if let data = try? result.get(), let image = UIImage(data: data) {
                self.imageView.image = image
            } else {
                self.retryButton.isHidden = false
            }
        }
    }
    
    func display(model: Beer) {
        self.taglineLabel.text = model.tagline
        self.abvLabel.text = "ABV: " + String(describing: model.abv)
        self.ibuLabel.text = "IBU: " + String(describing: model.ibu)
        self.descriptionLabel.text = model.description
        self.ibuLabel.isHidden = model.ibu == nil
        loadImage()
    }
    
    @objc func retryButtonTapped() {
        loadImage()
    }
}
