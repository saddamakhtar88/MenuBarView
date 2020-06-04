import Foundation
import UIKit

public protocol MenuBarProtocol {
    func onActiveMenuChange(index: Int)
    func decorateMenu(button: UIButton, forIndex: Int)
}

public enum MenuBarViewStyle {
    case Underline
    case Segment
}

public class MenuBarView: UIView {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let activeMenuView = UIView()
    private let bottomBorderView = UIView()
    
    private var scrollViewTrailingConstraint: NSLayoutConstraint!
    private var scrollViewLeadingConstraint: NSLayoutConstraint!
    
    private var activeMenuViewWidthConstraint: NSLayoutConstraint!
    private var activeMenuViewCenterConstraint: NSLayoutConstraint!
    private var activeMenuViewheightConstraint: NSLayoutConstraint!
    private var activeMenuViewTopConstraint: NSLayoutConstraint!
    private var activeMenuViewBottomConstraint: NSLayoutConstraint!
    
    private var bottomBorderViewViewheightConstraint: NSLayoutConstraint!
    
    private var prActiveMenuIndex: Int = 0
    
    public var delegate: MenuBarProtocol?
    
    public var contentEdgeInset: UIEdgeInsets? {
        didSet {
            let inset = contentEdgeInset ?? UIEdgeInsets.zero
            scrollViewLeadingConstraint.constant = inset.left
            scrollViewTrailingConstraint.constant = -inset.right
        }
    }
    
    public var style: MenuBarViewStyle = MenuBarViewStyle.Underline {
        didSet {
            switch style {
            case .Underline:
                applyUnderlineStyle()
            case .Segment:
                applySegmentStyle()
            }
            updateActiveMenuLayout()
            setNeedsLayout()
        }
    }
    
    public var menuSpacing: CGFloat = 8 {
        didSet {
            stackView.spacing = menuSpacing
            updateActiveMenuLayout()
            setNeedsLayout()
        }
    }
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
    
    public var activeMenuSegmentCornerRadius: CGFloat = 4.0 {
        didSet {
            if style == .Segment {
                activeMenuView.layer.cornerRadius = activeMenuSegmentCornerRadius
                setNeedsLayout()
            }
        }
    }
    
    public var activeMenuSegmentVerticalSpace: CGFloat = 4.0 {
        didSet {
            if style == .Segment {
                activeMenuViewTopConstraint.constant = activeMenuSegmentVerticalSpace
                activeMenuViewBottomConstraint.constant = -activeMenuSegmentVerticalSpace
                setNeedsLayout()
            }
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
                updateActiveMenuLayout()
                provideDecorationOpportunity()
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
        
        let inset = contentEdgeInset ?? UIEdgeInsets.zero
        let leftOutSpace = frame.width - stackView.frame.width - (inset.left + inset.right)
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
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: deltaInsetSpace, bottom: 0, right: deltaInsetSpace)
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
        let contentInset = contentEdgeInset ?? UIEdgeInsets.zero
        let isFirstMenu = stackView.arrangedSubviews.firstIndex(of: selectedMenu) == 0
        let isLastMenu = stackView.arrangedSubviews.firstIndex(of: selectedMenu) == stackView.arrangedSubviews.count - 1
        
        var widthDelta: CGFloat =  0
        var centerDelta: CGFloat = 0.0
        if style == .Underline {
            widthDelta = isFirstMenu ? contentInset.left : 0
            widthDelta += isLastMenu ? contentInset.right : 0
            if isFirstMenu && !isLastMenu {
                centerDelta = -(widthDelta/2.0)
            } else if isLastMenu && !isFirstMenu {
                centerDelta = widthDelta/2.0
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            self.activeMenuViewWidthConstraint.isActive = false
            self.activeMenuViewCenterConstraint.isActive = false
            
            self.activeMenuViewWidthConstraint = self.activeMenuView.widthAnchor.constraint(equalTo: selectedMenu.widthAnchor,
                                                                                            constant: widthDelta + self.menuSpacing)
            self.activeMenuViewCenterConstraint = self.activeMenuView.centerXAnchor.constraint(equalTo: selectedMenu.centerXAnchor,
                                                                                               constant: centerDelta)
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
    
    private func updateActiveMenuLayout() {
        if !stackView.arrangedSubviews.isEmpty {
            let button = stackView.arrangedSubviews[activeMenuIndex] as! UIButton
            animateSelectionChange(selectedMenu: button)
        }
    }
    
    private func provideDecorationOpportunity() {
        for (index, arrangedSubview) in stackView.arrangedSubviews.enumerated() {
            delegate?.decorateMenu(button: arrangedSubview as! UIButton,
                                   forIndex: index)
        }
    }
    
    private func applyUnderlineStyle() {
        activeMenuView.layer.cornerRadius = 0
        activeMenuViewheightConstraint.isActive = true
        activeMenuViewTopConstraint.isActive = false
        activeMenuViewTopConstraint.constant = 0
        activeMenuViewBottomConstraint.constant = 0
    }
    
    private func applySegmentStyle() {
        activeMenuView.layer.cornerRadius = activeMenuSegmentCornerRadius
        activeMenuViewheightConstraint.isActive = false
        activeMenuViewTopConstraint.isActive = true
        activeMenuViewTopConstraint.constant = activeMenuSegmentVerticalSpace
        activeMenuViewBottomConstraint.constant = -activeMenuSegmentVerticalSpace
    }
    
    private func initializeView() {
        clipsToBounds = true
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        addSubview(scrollView)
        
        scrollViewLeadingConstraint = scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        scrollViewLeadingConstraint.isActive = true
        scrollViewTrailingConstraint = scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        scrollViewTrailingConstraint.isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        activeMenuView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(activeMenuView)
        
        activeMenuViewheightConstraint = activeMenuView.heightAnchor.constraint(equalToConstant: activeMenuHighlightHeight)
        activeMenuViewheightConstraint.isActive = true
        
        activeMenuViewTopConstraint = activeMenuView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        activeMenuViewBottomConstraint = activeMenuView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        activeMenuViewBottomConstraint.isActive = true
        
        activeMenuView.backgroundColor = activeMenuHighlightColor
        
        activeMenuViewWidthConstraint = activeMenuView.widthAnchor.constraint(equalToConstant: 0)
        activeMenuViewCenterConstraint = activeMenuView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        
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
        
        switch style {
        case .Underline:
            applyUnderlineStyle()
        case .Segment:
            applySegmentStyle()
        }
    }
}
