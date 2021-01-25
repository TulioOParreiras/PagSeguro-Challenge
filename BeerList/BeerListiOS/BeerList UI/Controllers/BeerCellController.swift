//
//  BeerCellController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit

protocol BeerCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class BeerCellController: BeerView {
    private let delegate: BeerCellControllerDelegate
    private lazy var cell = BeerCell()
    
    init(delegate: BeerCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
    
    func display(_ viewModel: BeerViewModel<UIImage>) {
        cell.ibuLabel.isHidden = !viewModel.hasIbu
        cell.ibuLabel.text = viewModel.ibu
        cell.nameLabel.text = viewModel.name
        cell.beerImageView.image = viewModel.image
        cell.imageContainer.isShimmering = viewModel.isLoading
        cell.beerImageReturnButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = delegate.didRequestImage

    }

}
