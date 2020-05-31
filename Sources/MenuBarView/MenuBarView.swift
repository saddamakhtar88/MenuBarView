import Foundation
import UIKit

protocol MenuBarProtocol {
    func onMenuTap(index: Int)
    func decorateMenu(button: UIButton, forIndex: Int)
}

class MenuBarView: UIView {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let activeMenuView = UIView()
    private let bottomBorderView = UIView()
    
    private var activeMenuViewWidthConstraint: NSLayoutConstraint!
    private var activeMenuViewCenterConstraint: NSLayoutConstraint!
    private var activeMenuViewheightConstraint: NSLayoutConstraint!
    
    private var bottomBorderViewViewheightConstraint: NSLayoutConstraint!
    
    var delegate: MenuBarProtocol?
    
    var contentEdgeInset: UIEdgeInsets?
    var menuSpacing: CGFloat = 8
    var activeMenuHighlightHeight: CGFloat = 8 {
        didSet {
            activeMenuViewheightConstraint.constant = activeMenuHighlightHeight
        }
    }
    var activeMenuHighlightColor = UIColor.red {
        didSet {
            activeMenuView.backgroundColor = activeMenuHighlightColor
        }
    }
    
    var bottomBorderHeight : CGFloat = 0.5 {
        didSet {
            bottomBorderViewViewheightConstraint.constant = bottomBorderHeight
        }
    }
    var bottomBorderColor = UIColor.lightGray {
        didSet {
            bottomBorderView.backgroundColor = bottomBorderColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initializeView()
    }
    
    final public func setMenu(labels: [String], distribution: UIStackView.Distribution = .fillProportionally) {
        resetStackView()
        stackView.spacing = menuSpacing
        stackView.distribution = distribution
        
        for index in 0..<labels.count {
            let button = UIButton()
            button.setTitle(labels[index], for: .normal)

            delegate?.decorateMenu(button: button, forIndex: index)
            
            if index == 0 {
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: contentEdgeInset?.left ?? 0, bottom: 0, right: 0)
            } else if index == labels.count  - 1 {
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: contentEdgeInset?.left ?? 0)
            }
            
            stackView.addArrangedSubview(button)
            
            button.addTarget(self, action: #selector(self.pressed(sender:)), for: .touchUpInside)
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
        animateSelectionChange(selectedMenu: sender)
        let index = stackView.arrangedSubviews.firstIndex(of: sender)
        delegate?.onMenuTap(index: index ?? -1)
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
        stackView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor).isActive = true
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
