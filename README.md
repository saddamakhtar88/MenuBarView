# MenuBarView

A UIView derivative for menu view

## MenuBarProtocol
    * func onMenuTap(index: Int)
    * func decorateMenu(button: UIButton, forIndex: Int)

## Public APIs

- setMenu(labels: [String])
- contentEdgeInset: UIEdgeInsets?
- menuSpacing: CGFloat = 8
- activeMenuHighlightHeight: CGFloat = 8
- activeMenuHighlightColor = UIColor.red
- bottomBorderHeight : CGFloat = 0.5
- bottomBorderColor = UIColor.lightGray
