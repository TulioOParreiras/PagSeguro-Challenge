//
//  BeerListCellController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerList

final class BeerListCellController {
    private var task: BeerImageDataLoaderTask?
    private let model: Beer
    private let imageLoader: BeerImageDataLoader
    
    init(model: Beer, imageLoader: BeerImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = BeerCell()
        cell.ibuLabel.isHidden = model.ibu == nil
        cell.ibuLabel.text = String(describing: model.ibu ?? 0)
        cell.nameLabel.text = model.name
        cell.beerImageView.image = nil
        cell.beerImageReturnButton.isHidden = true
        cell.imageContainer.startShimmering()
        let loadImage = { [weak cell, weak self] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadImageData(from: self.model.imageURL) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.beerImageView.image = image
                cell?.beerImageReturnButton.isHidden = image != nil
                cell?.imageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: self.model.imageURL) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
