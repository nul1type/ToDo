//
//  CheckboxButton.swift
//  ToDo
//
//  Created by Анатолий Александрович on 24.07.2025.
//

import UIKit

class CheckboxButton: UIButton {
    
    private var outerCircleLayer = CAShapeLayer()
    private var innerCircleLayer = CAShapeLayer()
    private var checkmarkLayer = CAShapeLayer()
    
    var outerCircleColor: UIColor = .systemGray3 {
        didSet { outerCircleLayer.strokeColor = outerCircleColor.cgColor }
    }
    var innerCircleColor: UIColor = .systemOrange {
        didSet { innerCircleLayer.fillColor = innerCircleColor.cgColor }
    }
    var checkmarkColor: UIColor = .white {
        didSet { checkmarkLayer.strokeColor = checkmarkColor.cgColor }
    }
    
    var circleLineWidth: CGFloat = 1.5
    var checkmarkLineWidth: CGFloat = 2.0
    
//    override var isSelected: Bool {
//        didSet { updateState(animated: true) }
//    }
    
    func setSelectedWithoutAnimation(_ isSelected: Bool) {
        if isSelected {
            innerCircleLayer.fillColor = innerCircleColor.cgColor
            innerCircleLayer.opacity = 1.0
            checkmarkLayer.strokeEnd = 1.0
        } else {
            innerCircleLayer.opacity = 0.0
            checkmarkLayer.strokeEnd = 0.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        addTarget(self, action: #selector(toggleState), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        addTarget(self, action: #selector(toggleState), for: .touchUpInside)
    }
    
    private func setupLayers() {
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.strokeColor = outerCircleColor.cgColor
        outerCircleLayer.lineWidth = circleLineWidth
        layer.addSublayer(outerCircleLayer)
        
        innerCircleLayer.fillColor = UIColor.clear.cgColor
        innerCircleLayer.opacity = 0
        layer.addSublayer(innerCircleLayer)
        
        checkmarkLayer.fillColor = UIColor.clear.cgColor
        checkmarkLayer.strokeColor = checkmarkColor.cgColor
        checkmarkLayer.lineWidth = checkmarkLineWidth
        checkmarkLayer.lineCap = .round
        checkmarkLayer.lineJoin = .round
        checkmarkLayer.strokeEnd = 0
        layer.addSublayer(checkmarkLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let circleRect = bounds.insetBy(dx: circleLineWidth/2, dy: circleLineWidth/2)
        let circlePath = UIBezierPath(ovalIn: circleRect)
        
        outerCircleLayer.path = circlePath.cgPath
        innerCircleLayer.path = circlePath.cgPath
        
        let checkmarkPath = UIBezierPath()
        let inset: CGFloat = bounds.width * 0.25
        checkmarkPath.move(to: CGPoint(x: inset, y: bounds.midY))
        checkmarkPath.addLine(to: CGPoint(x: bounds.midX - inset/3, y: bounds.midY + inset))
        checkmarkPath.addLine(to: CGPoint(x: bounds.width - inset, y: inset))
        
        checkmarkLayer.path = checkmarkPath.cgPath
    }
    
    public func updateState(animated: Bool) {
        if isSelected {
            showSelectedState(animated: animated)
        } else {
            showDeselectedState(animated: animated)
        }
    }
    
    private func showSelectedState(animated: Bool) {
        let circleAnimation = CABasicAnimation(keyPath: "opacity")
        circleAnimation.toValue = 1.0
        
        let checkmarkAnimation = CABasicAnimation(keyPath: "strokeEnd")
        checkmarkAnimation.toValue = 1.0
        
        if animated {
            circleAnimation.duration = 0.2
            checkmarkAnimation.duration = 0.3
            checkmarkAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        }
        
        innerCircleLayer.fillColor = innerCircleColor.cgColor
        innerCircleLayer.add(circleAnimation, forKey: nil)
        innerCircleLayer.opacity = 1
        
        checkmarkLayer.add(checkmarkAnimation, forKey: nil)
        checkmarkLayer.strokeEnd = 1
    }
    
    private func showDeselectedState(animated: Bool) {
        let circleAnimation = CABasicAnimation(keyPath: "opacity")
        circleAnimation.toValue = 0.0
        
        if animated {
            circleAnimation.duration = 0.2
        }
        
        innerCircleLayer.add(circleAnimation, forKey: nil)
        innerCircleLayer.opacity = 0
        
        checkmarkLayer.strokeEnd = 0
    }
    
    @objc private func toggleState() {
        isSelected.toggle()
    }
}
