//
//  BeerCell+TestHelpers.swift
//  BeerListiOSTests
//
//  Created by Tulio Parreiras on 25/01/21.
//

import UIKit
import BeerListiOS

extension BeerCell {
    var isShowingIbu: Bool {
        return !abvLabel.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        imageContainer.isShimmering
    }
    
    var nameText: String? {
        return nameLabel.text
    }
    
    var renderedImage: Data? {
        return beerImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        return !beerImageReturnButton.isHidden
    }
    
    func simulateRetryAction() {
        beerImageReturnButton.simulateEvent(.touchUpInside)
    }
}
