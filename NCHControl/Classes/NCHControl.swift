//
//  NCHControl.swift
//  NCHControl
//
//  Created by Chi Hoang on 30/4/20.
//  Copyright © 2020 Hoang Nguyen Chi. All rights reserved.
//

import UIKit

public protocol NCHControlDelegate: class {
    func numberOfItems(inTab tabSwitcher: NCHControl) -> Int
    func tab(_ tabSwitcher: NCHControl, titleAt index: Int) -> String
    func tab(_ tabSwitcher: NCHControl, iconAt index: Int) -> UIImage
}

public class NCHControl: UIControl {
    public weak var dataSource: NCHControlDelegate?
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private var labels: [UILabel] = []
    
    private(set) lazy var highlighterView: UIView = {
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: self.bounds.height))
        let highlighterView = UIView(frame: frame)
        highlighterView.backgroundColor = UIColor.blue
        highlighterView.layer.cornerRadius = (self.bounds.height) / 2
        addSubview(highlighterView)
        sendSubviewToBack(highlighterView)
        return highlighterView
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override public var frame: CGRect {
        didSet {
            stackView.frame = bounds
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            stackView.frame = bounds
        }
    }
    
    public var selectedSegmentIndex: Int = 0 {
        didSet {
            if oldValue != selectedSegmentIndex {
                transition(from: oldValue, to: selectedSegmentIndex)
                sendActions(for: .valueChanged)
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        moveHighlighterView(toItemAt: selectedSegmentIndex)
        layer.cornerRadius = self.stackView.frame.height / 2.0
    }
    
    public func reloadData() {
        guard let dataSource = dataSource else { return }
        selectedSegmentIndex = 0
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        buttons = []
        labels = []
        
        let count = dataSource.numberOfItems(inTab: self)
        for index in 0..<count {
            let button = createButton(forIndex: index, withDataSource: dataSource)
            buttons.append(button)
            stackView.addArrangedSubview(button)
            
            let label = createLabel(forIndex: index, withDataSource: dataSource)
            labels.append(label)
            stackView.addArrangedSubview(label)
        }
        layoutIfNeeded()
        transition(from: selectedSegmentIndex, to: selectedSegmentIndex)
    }
    
    func commonInit() {
        backgroundColor = UIColor.white
        addSubview(stackView)
        stackView.distribution = .fillEqually
    }
}

private extension NCHControl {
    func createButton(forIndex index: Int, withDataSource dataSource: NCHControlDelegate) -> UIButton {
        let button = UIButton()
        button.addTarget(self, action: #selector(selectButton(_:)), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.image?.withRenderingMode(.alwaysTemplate)
        let image = dataSource.tab(self, iconAt: index).withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: UIControl.State())
        button.tintColor = UIColor.gray
        return button
    }
    func createLabel(forIndex index: Int, withDataSource dataSource: NCHControlDelegate) -> UILabel {
        let label = UILabel()
        label.isHidden = true
        label.textAlignment = .left
        label.text = dataSource.tab(self, titleAt: index)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    @objc
    func selectButton(_ sender: UIButton) {
        if let index = buttons.firstIndex(of: sender) {
            selectedSegmentIndex = index
        }
    }
    func transition(from fromIndex: Int, to toIndex: Int) {
        guard let fromLabel = labels[safe: fromIndex],
            let fromIcon = buttons[safe: fromIndex],
            let toLabel = labels[safe: toIndex],
            let toIcon = buttons[safe: toIndex] else {
                return
        }
        
        let animation = {
            fromLabel.isHidden = true
            fromLabel.alpha = 0
            fromIcon.isSelected = false
            fromIcon.tintColor = UIColor.gray
            
            toLabel.isHidden = false
            toLabel.alpha = 1
            toIcon.isSelected = true
            toIcon.tintColor = UIColor.white
            
            self.moveHighlighterView(toItemAt: toIndex)
        }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 3,
            options: [],
            animations: animation,
            completion: nil
        )
    }
    
    func moveHighlighterView(toItemAt toIndex: Int) {
        guard let countItems = dataSource?.numberOfItems(inTab: self), countItems > toIndex else {
            return
        }
        stackView.layoutIfNeeded()
        
        let toLabel = labels[toIndex]
        let toIcon = buttons[toIndex]
        let point = convert(toIcon.frame.origin, to: self)
        highlighterView.frame.origin.x = point.x
        
        // set offset for the first item and the last item
        if toIndex == 0 {
            highlighterView.frame.origin.x = point.x
        } else if toIndex == countItems - 1 {
            highlighterView.frame.origin.x = point.x
        }
        highlighterView.frame.size.width = toLabel.bounds.width + (toLabel.frame.origin.x - toIcon.frame.origin.x)
    }
}


extension Array {
    subscript (safe index: Int) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
