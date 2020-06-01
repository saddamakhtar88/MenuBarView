# MenuBarView

A UIView derivative for menu view

## Public APIs

### Functions 
- setMenu(labels: [String], defaultActive: Int = 0)
- setActiveMenu(index: Int)

### Properties
- contentEdgeInset: UIEdgeInsets?
- menuSpacing: CGFloat = 8
- activeMenuHighlightHeight: CGFloat = 8
- activeMenuHighlightColor = UIColor.red
- bottomBorderHeight : CGFloat = 0.5
- bottomBorderColor = UIColor.lightGray

## Delegate <MenuBarProtocol>
- func onMenuTap(index: Int)
- func decorateMenu(button: UIButton, forIndex: Int)
