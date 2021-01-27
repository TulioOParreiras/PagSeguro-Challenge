//
//  BeerCellController.swift
//  BeerListiOS
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerList

public protocol BeerCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class BeerCellController: BeerView {
    private let delegate: BeerCellControllerDelegate
    public let selection: () -> Void
    private var cell: BeerCell?
    
    public init(delegate: BeerCellControllerDelegate, selection: @escaping() -> Void) {
        self.delegate = delegate
        self.selection = selection
    }
    
    func view(_ tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    public func display(_ viewModel: BeerViewModel<UIImage>) {
        cell?.abvLabel.text = viewModel.abv
        cell?.nameLabel.text = viewModel.name
        cell?.beerImageView?.setImageAnimated(viewModel.image)
        cell?.imageContainer.isShimmering = viewModel.isLoading
        cell?.beerImageReturnButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }

}
