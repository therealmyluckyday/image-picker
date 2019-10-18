//
//  ImagePickerLayout.swift
//  Image Picker
//
//  Created by Peter Stajger on 05/09/2017.
//  Copyright © 2017 Inloop. All rights reserved.
//

import Foundation

///
/// A helper class that contains all code and logic when doing layout of collection
/// view cells. This is used sollely by collection view's delegate. Typically 
/// this code should be part of regular subclass of UICollectionViewLayout, however,
/// since we are using UICollectionViewFlowLayout we have to do this workaround.
///
final class ImagePickerLayout {

    deinit {
        log("deinit: \(String(describing: self))")
    }
    
    var configuration: LayoutConfiguration
    
    init(configuration: LayoutConfiguration) {
        self.configuration = configuration
    }
    
    /// Returns size for item considering number of rows and scroll direction, if preferredWidthOrHeight is nil, square size is returned
    func sizeForItem(numberOfItemsInRow: Int, preferredWidthOrHeight: CGFloat?, collectionView: UICollectionView, scrollDirection: UICollectionView.ScrollDirection) -> CGSize {
        
        switch scrollDirection {
        case .horizontal:
            var itemHeight = collectionView.frame.height
            itemHeight -= (collectionView.contentInset.top + collectionView.contentInset.bottom)
            itemHeight -= (CGFloat(numberOfItemsInRow) - 1) * configuration.interitemSpacing
            itemHeight /= CGFloat(numberOfItemsInRow)
            return CGSize(width: preferredWidthOrHeight ?? itemHeight, height: itemHeight)
            
        case .vertical:
            var itemWidth = collectionView.frame.width
            itemWidth -= (collectionView.contentInset.left + collectionView.contentInset.right)
            itemWidth -= (CGFloat(numberOfItemsInRow) - 1) * configuration.interitemSpacing
            itemWidth /= CGFloat(numberOfItemsInRow)
            return CGSize(width: itemWidth, height: preferredWidthOrHeight ?? itemWidth)
            
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("currently only UICollectionViewFlowLayout is supported")
        }
        
        let layoutModel = LayoutModel(configuration: configuration, assets: 0)
        
        switch indexPath.section {
        case configuration.sectionIndexForActions:
            //this will make sure that action item is either square if there are 2 items,
            //or a recatangle if there is only 1 item
            //let width = sizeForItem(numberOfItemsInRow: 2, preferredWidthOrHeight: nil, collectionView: collectionView, scrollDirection: layout.scrollDirection).width
            let ratio: CGFloat = 0.25
            let width = collectionView.frame.width * ratio
            return sizeForItem(numberOfItemsInRow: layoutModel.numberOfItems(in: configuration.sectionIndexForActions), preferredWidthOrHeight: width, collectionView: collectionView, scrollDirection: layout.scrollDirection)
            
        case configuration.sectionIndexForCamera:
            //lets keep this ratio so camera item is a nice rectangle
            
            let traitCollection = collectionView.traitCollection
            
            var ratio: CGFloat = 160/212
            
            //for iphone in landscape we need different ratio
            switch traitCollection.userInterfaceIdiom {
            case .phone:
                switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
                //iphones in landscape
                case (.unspecified, .compact):
                    fallthrough
                //iphones+ in landscape
                case (.regular, .compact):
                    fallthrough
                //iphones in landscape except iphone +
                case (.compact, .compact):
                    ratio = 1/ratio
                default: break
                }
                
            default:
                break
            }
            
            let widthOrHeight: CGFloat = collectionView.frame.height * ratio
            return sizeForItem(numberOfItemsInRow: layoutModel.numberOfItems(in: configuration.sectionIndexForCamera), preferredWidthOrHeight: widthOrHeight, collectionView: collectionView, scrollDirection: layout.scrollDirection)
            
        case configuration.sectionIndexForAssets:
            //make sure there is at least 1 item, othewise invalid layout
            assert(configuration.numberOfAssetItemsInRow > 0, "invalid layout - numberOfAssetItemsInRow must be > 0, check your layout configuration ")
            return sizeForItem(numberOfItemsInRow: configuration.numberOfAssetItemsInRow, preferredWidthOrHeight: nil, collectionView: collectionView, scrollDirection: layout.scrollDirection)
            
        default:
            fatalError("unexpected sections count")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("currently only UICollectionViewFlowLayout is supported")
        }
        
        /// helper method that creates edge insets considering scroll direction
        func sectionInsets(_ inset: CGFloat) -> UIEdgeInsets {
            switch layout.scrollDirection {
            case .horizontal: return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: inset)
            case .vertical: return UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
            default: return UIEdgeInsets.zero
            }
        }
        
        let layoutModel = LayoutModel(configuration: configuration, assets: 0)
        
        switch section {
        case 0 where layoutModel.numberOfItems(in: section) > 0:
            return sectionInsets(configuration.actionSectionSpacing)
        case 1 where layoutModel.numberOfItems(in: section) > 0:
            return sectionInsets(configuration.cameraSectionSpacing)
        default:
            return .zero
        }
    }
    
}
