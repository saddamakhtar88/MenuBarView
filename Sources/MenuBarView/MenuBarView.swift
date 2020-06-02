import Foundation
import UIKit

public protocol MenuBarProtocol {
    func onActiveMenuChange(index: Int)
    func decorateMenu(button: UIButton, forIndex: Int)
}

public class MenuBarView: UIView {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let activeMenuView = UIView()
    private let bottomBorderView = UIView()
    
    private var activeMenuViewWidthConstraint: NSLayoutConstraint!
    private var activeMenuViewCenterConstraint: NSLayoutConstraint!
    private var activeMenuViewheightConstraint: NSLayoutConstraint!
    
    private var bottomBorderViewViewheightConstraint: NSLayoutConstraint!
    
    private var prActiveMenuIndex: Int = 0
    
    public var delegate: MenuBarProtocol?
    
    public var contentEdgeInset: UIEdgeInsets?
    public var menuSpacing: CGFloat = 8
    public var activeMenuHighlightHeight: CGFloat = 8 {
        didSet {
            activeMenuViewheightConstraint.constant = activeMenuHighlightHeight
        }
    }
    public var activeMenuHighlightColor = UIColor.red {
        didSet {
            activeMenuView.backgroundColor = activeMenuHighlightColor
        }
    }
    
    public var bottomBorderHeight : CGFloat = 0.5 {
        didSet {
            bottomBorderViewViewheightConstraint.constant = bottomBorderHeight
        }
    }
    public var bottomBorderColor = UIColor.lightGray {
        didSet {
            bottomBorderView.backgroundColor = bottomBorderColor
        }
    }
    
    final public var activeMenuIndex: Int {
        get {
            prActiveMenuIndex
        }
        set {
            if newValue > -1 &&
                newValue < stackView.arrangedSubviews.count &&
                newValue != prActiveMenuIndex {
                prActiveMenuIndex = newValue
                delegate?.onActiveMenuChange(index: prActiveMenuIndex)
                let button = stackView.arrangedSubviews[prActiveMenuIndex] as! UIButton
                animateSelectionChange(selectedMenu: button)
                for (index, arrangedSubview) in stackView.arrangedSubviews.enumerated() {
                    delegate?.decorateMenu(button: arrangedSubview as! UIButton,
                                           forIndex: index)
                }
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initializeView()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        updateButtonInsetsToExpandStackView(leftOutSpaceToFill: 0)
        stackView.layoutIfNeeded()
        
        let leftOutSpace = frame.width - stackView.frame.width
        updateButtonInsetsToExpandStackView(leftOutSpaceToFill: leftOutSpace > 0 ? leftOutSpace : 0)
    }
    
    final public func setMenu(labels: [String], defaultActive: Int = 0) {
        
        guard labels.count > 0 else {
            return
        }
        
        resetStackView()
        stackView.spacing = menuSpacing
        stackView.distribution = .fill
        
        for index in 0..<labels.count {
            let button = UIButton()
            button.setTitle(labels[index], for: .normal)
            
            delegate?.decorateMenu(button: button, forIndex: index)
            
            if labels.count == 1 {
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: contentEdgeInset?.left ?? 0, bottom: 0, right: contentEdgeInset?.right ?? 0)
            } else if index == 0 {
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: contentEdgeInset?.left ?? 0, bottom: 0, right: 0)
            } else if index == labels.count - 1 {
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: contentEdgeInset?.right ?? 0)
            }
            
            stackView.addArrangedSubview(button)
            
            button.addTarget(self, action: #selector(self.pressed(sender:)), for: .touchUpInside)
        }
        
        prActiveMenuIndex = defaultActive > -1 && defaultActive < stackView.arrangedSubviews.count ? defaultActive : 0
        animateSelectionChange(selectedMenu: stackView.arrangedSubviews[prActiveMenuIndex] as! UIButton)
    }
    
    private func updateButtonInsetsToExpandStackView(leftOutSpaceToFill: CGFloat) {
        let menuViews = stackView.arrangedSubviews
        let deltaInsetSpace = (leftOutSpaceToFill / CGFloat(menuViews.count)) / 2.0
        
        for index in 0..<menuViews.count {
            if let button = menuViews[index] as? UIButton {
                
                if menuViews.count == 1 {
                    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: (contentEdgeInset?.left ?? 0) + deltaInsetSpace, bottom: 0, right: (contentEdgeInset?.right ?? 0) + deltaInsetSpace)
                } else if index == 0 {
                    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: (contentEdgeInset?.left ?? 0) + deltaInsetSpace, bottom: 0, right: deltaInsetSpace)
                } else if index == menuViews.count - 1 {
                    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: deltaInsetSpace, bottom: 0, right: (contentEdgeInset?.right ?? 0) + deltaInsetSpace)
                } else {
                    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: deltaInsetSpace, bottom: 0, right: deltaInsetSpace)
                }
            }
        }
    }
    
    private func resetStackView() {
        let menuViews = stackView.arrangedSubviews
        menuViews.forEach { (view) in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    @objc private func pressed(sender: UIButton!) {
        let menuIndex = stackView.arrangedSubviews.firstIndex(of: sender) ?? -1
        activeMenuIndex = menuIndex
    }
    
    private func animateSelectionChange(selectedMenu: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.activeMenuViewWidthConstraint.isActive = false
            self.activeMenuViewCenterConstraint.isActive = false
            self.activeMenuViewWidthConstraint = self.activeMenuView.widthAnchor.constraint(equalTo: selectedMenu.widthAnchor, constant: self.menuSpacing)
            self.activeMenuViewCenterConstraint = self.activeMenuView.centerXAnchor.constraint(equalTo: selectedMenu.centerXAnchor)
            self.activeMenuViewWidthConstraint.isActive = true
            self.activeMenuViewCenterConstraint.isActive = true
            self.layoutIfNeeded()
        }
        
        let menuFrame = CGRect(origin: CGPoint(x: selectedMenu.frame.origin.x - (menuSpacing / 2),
                                               y: selectedMenu.frame.origin.y),
                               size: CGSize(width: selectedMenu.frame.width + menuSpacing,
                                            height: selectedMenu.frame.height))
        
        scrollView.scrollRectToVisible(menuFrame, animated: true)
    }
    
    private func initializeView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView);
        
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBorderView);
        
        bottomBorderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomBorderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomBorderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomBorderView.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor).isActive = true
        bottomBorderViewViewheightConstraint = bottomBorderView.heightAnchor.constraint(equalToConstant: bottomBorderHeight)
        bottomBorderViewViewheightConstraint.isActive = true
        bottomBorderView.backgroundColor = bottomBorderColor
        
        activeMenuView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(activeMenuView)
        
        activeMenuViewheightConstraint = activeMenuView.heightAnchor.constraint(equalToConstant: activeMenuHighlightHeight)
        activeMenuViewheightConstraint.isActive = true
        activeMenuView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        activeMenuView.backgroundColor = activeMenuHighlightColor
        
        activeMenuViewWidthConstraint = activeMenuView.widthAnchor.constraint(equalToConstant: 0)
        activeMenuViewCenterConstraint = activeMenuView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
    }
}
