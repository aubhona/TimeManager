//
//  TagViewCell.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 26.03.2024.
//

import Foundation
import UIKit

internal final class TagCollectionViewCell: UICollectionViewCell {
    public static let reuseIdentifier = "TagCollectionViewCell"
    
    private var tagView: TagView = TagView()
    public var isTapped: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 5
        configureTagView()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.transform = CGAffineTransform.identity
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        isTapped = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureTagView() {
        addSubview(tagView)
        tagView.pinVertical(to: self)
        tagView.pinRight(to: self)
        tagView.pinLeft(to: self, 5)
    }
    
    public func configureTag(name: String, color: UIColor) {
        tagView.configure(with: name, color: color)
    }
}
