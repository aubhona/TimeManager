//
//  TagViewCell.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 26.03.2024.
//

import Foundation
import UIKit
 
public final class TagViewCell: UICollectionViewCell {
    public static let reuseIdentifier = "TagCollectionViewCell"
    
    private var tagView: TagView = TagView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 5
        configureTagView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureTagView() {
        addSubview(tagView)
        tagView.pin(to: self)
    }
    
    public func configureTag(name: String, color: UIColor) {
        tagView.configure(with: name, color: color)
    }
}
