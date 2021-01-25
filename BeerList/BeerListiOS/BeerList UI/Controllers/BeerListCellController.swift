//
//  BeerListCellController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit

final class BeerListCellController {
    private var task: BeerImageDataLoaderTask?
    private let viewModel: BeerImageViewModel
    
    init(viewModel: BeerImageViewModel) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = binded(BeerCell())
        viewModel.loadImageData()
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ cell: BeerCell) -> BeerCell {
        cell.ibuLabel.isHidden = viewModel.ibu == nil
        cell.ibuLabel.text = viewModel.ibu
        cell.nameLabel.text = viewModel.name
        cell.beerImageView.image = nil
        cell.beerImageReturnButton.isHidden = true
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.beerImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.imageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.beerImageReturnButton.isHidden = !shouldRetry
        }
        
        return cell

    }

}
