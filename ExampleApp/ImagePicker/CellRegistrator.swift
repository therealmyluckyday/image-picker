//
//  CellRegistrator.swift
//  ExampleApp
//
//  Created by Peter Stajger on 06/09/2017.
//  Copyright © 2017 Inloop. All rights reserved.
//

import Foundation
import UIKit

///
/// Use this class to register various cell nibs or classes for each item type.
///
/// Supported item types:
/// 1. action item - there can be multiple action items
/// 2. asset item - each asset can have multiple types (image, video, burst, etc..)
///
public final class CellRegistrator {
    
    // MARK: Private Methods
    
    fileprivate let actionItemIdentifierPrefix = "eu.inloop.action-item.cell-id"
    fileprivate var actionItemNibsData: [Int: (UINib, String)]?
    fileprivate var actionItemClassesData: [Int: (UICollectionViewCell.Type, String)]?
    
    fileprivate let assetItemIdentifierPrefix = "eu.inloop.asset-item.cell-id"
    fileprivate var assetItemNibsData: [AssetType: (UINib, String)]?
    fileprivate var assetItemClassesData: [AssetType: (UICollectionViewCell.Type, String)]?
    
    // MARK: Internal Methods
    
    let cellIdentifierForCameraItem = "eu.inloop.camera-item.cell-id"
    
    func cellIdentifier(forActionItemAt index: Int) -> String? {
        return actionItemNibsData?[index]?.1 ?? actionItemClassesData?[index]?.1
    }
    
    func cellIdentifier(forAsset type: AssetType) -> String? {
        return assetItemNibsData?[type]?.1 ?? assetItemClassesData?[type]?.1
    }
    
    // MARK: Public Methods
    
    public init() {
    
    }
    
    public func register(nib: UINib, forActionItemAt index: Int) {
        if actionItemNibsData == nil {
            actionItemNibsData = [:]
        }
        let cellIdentifier = actionItemIdentifierPrefix + String(index)
        actionItemNibsData?[index] = (nib, cellIdentifier)
    }
    
    public func register(nib: UINib, forAssetItemOf type: AssetType) {
        if assetItemNibsData == nil {
            assetItemNibsData = [:]
        }
        let cellIdentifier = assetItemIdentifierPrefix + String(describing: type)
        assetItemNibsData?[type] = (nib, cellIdentifier)
    }
    
    public func register(class: UICollectionViewCell.Type, forActionItemAt index: Int) {
        if actionItemClassesData == nil {
            actionItemClassesData = [:]
        }
        let cellIdentifier = actionItemIdentifierPrefix + String(index)
        actionItemClassesData?[index] = (`class`, cellIdentifier)
    }
    
    public func register(class: UICollectionViewCell.Type, forAssetItemOf type: AssetType) {
        if assetItemClassesData == nil {
            assetItemClassesData = [:]
        }
        let cellIdentifier = assetItemIdentifierPrefix + String(describing: type)
        assetItemClassesData?[type] = (`class`, cellIdentifier)
    }
    
}

extension UICollectionView {
    
    func apply(registrator: CellRegistrator) {
        register(nibsData: registrator.actionItemNibsData?.map { $1 })
        register(nibsData: registrator.assetItemNibsData?.map { $1 })
        register(classData: registrator.actionItemClassesData?.map { $1 })
        register(classData: registrator.assetItemClassesData?.map { $1 })
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: registrator.cellIdentifierForCameraItem)
    }
    
    /// Helper func that takes nib,cellid pair and registers them on a collection view
    fileprivate func register(nibsData: [(UINib, String)]?) {
        guard let nibsData = nibsData else { return }
        for (nib, cellIdentifier) in nibsData {
            register(nib, forCellWithReuseIdentifier: cellIdentifier)
        }
    }
    
    /// Helper func that takes nib,cellid pair and registers them on a collection view
    fileprivate func register(classData: [(UICollectionViewCell.Type, String)]?) {
        guard let classData = classData else { return }
        for (cellType, cellIdentifier) in classData {
            register(cellType, forCellWithReuseIdentifier: cellIdentifier)
        }
    }
    
}
