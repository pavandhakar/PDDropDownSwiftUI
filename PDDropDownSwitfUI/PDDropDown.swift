
import UIKit

/// A feature-rich, searchable dropdown field built on `UITextField`.
///
/// Use `PDDropDownSwiftUIView` to embed this in SwiftUI, or drop it directly
/// into UIKit storyboards / code. Configure via `IBInspectable` attributes in
/// Interface Builder or set the public properties in code.
open class PDDropDown: UITextField {
    var arrow: Arrow!
    var table: UITableView!
    var shadow: UIView!
    /// Index of the currently selected option inside `optionArray`.
    public var selectedIndex: Int?

    // MARK: IBInspectable

    /// Height of each row in the dropdown list. Default `30`.
    @IBInspectable public var rowHeight: CGFloat = 30
    /// Background colour of unselected rows.
    @IBInspectable public var rowBackgroundColor: UIColor = .white
    /// Text colour of option labels.
    @IBInspectable public var itemsColor: UIColor = .darkGray
    /// Tint colour used for the check-mark accessory.
    @IBInspectable public var itemsTintColor: UIColor = .blue
    /// Background colour applied to the selected row.
    @IBInspectable public var selectedRowColor: UIColor = .clear
    /// When `true` the list is dismissed automatically after a row is tapped.
    @IBInspectable public var hideOptionsWhenSelect = true
    /// Enables live-search filtering. When `true` the field becomes editable.
    @IBInspectable public var isSearchEnable: Bool = true {
        didSet {
            addGesture()
        }
    }

    @IBInspectable public var borderColor: UIColor = UIColor.lightGray {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable public var listHeight: CGFloat = 150 {
        didSet {
        }
    }

    /// Fixed width of the dropdown list. When `nil` the list matches the text field's width.
    public var listWidth: CGFloat?
    /// Horizontal shift of the list relative to the text field's origin (legacy). Default `0`.
    public var listXOffset: CGFloat = 0

    /// Insets the list's **leading** edge by this amount relative to the text field (positive = inward).
    public var listLeadingOffset: CGFloat = 0

    /// Insets the list's **trailing** edge by this amount relative to the text field (positive = inward).
    public var listTrailingOffset: CGFloat = 0

    /// Computed x-origin and width for the dropdown table, honouring
    /// `listLeadingOffset`, `listTrailingOffset`, `listXOffset`, and `listWidth`.
    private var resolvedTableXAndWidth: (x: CGFloat, width: CGFloat) {
        let baseX = pointToParent.x
        let baseWidth = listWidth ?? frame.width
        if listLeadingOffset != 0 || listTrailingOffset != 0 {
            let x = baseX + listLeadingOffset
            let width = baseWidth - listLeadingOffset - listTrailingOffset
            return (x, max(width, 0))
        }
        return (baseX + listXOffset, baseWidth)
    }

    /// Width of the text-field border. `0` hides it.
    @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    /// Corner radius applied to the text field layer.
    @IBInspectable public var cornerRadius: CGFloat = 5.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    // MARK: - Private state
    fileprivate var tableheightX: CGFloat = 100
    fileprivate var dataArray = [String]()
    fileprivate var imageArray = [String]()
    fileprivate var pointToParent = CGPoint(x: 0, y: 0)
    fileprivate var backgroundView = UIView()
    fileprivate var keyboardHeight: CGFloat = 0

    /// The view that the dropdown table and shadow are added to.
    /// Using the `UIWindow` keeps this safe in both UIKit and SwiftUI (UIHostingController)
    /// contexts — adding to UIHostingController.view directly is unsupported.
    private var overlayContainer: UIView? {
        // Prefer the window this view is currently attached to.
        if let w = self.window { return w }
        // Fallback: find the key window via connected scenes.
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    /// The full set of options displayed in the dropdown list.
    public var optionArray = [String]() {
        didSet {
            dataArray = optionArray
        }
    }

    /// Optional image names (from the asset catalogue) shown beside each option.
    public var optionImageArray = [String]() {
        didSet {
            imageArray = optionImageArray
        }
    }

    /// Optional integer identifiers aligned 1-to-1 with `optionArray`.
    /// Passed back to the `didSelect` closure as the `id` parameter.
    public var optionIds: [Int]?
    var searchText = String() {
        didSet {
            if searchText == "" {
                dataArray = optionArray
            } else {
                dataArray = optionArray.filter {
                    searchFilter(text: $0, searchText: searchText)
                }
            }
            reSizeTable()
            selectedIndex = nil
            table.reloadData()
        }
    }

    /// Side-length of the arrow icon in points.
    @IBInspectable public var arrowSize: CGFloat = 15 {
        didSet {
            let center = arrow.superview!.center
            arrow.frame = CGRect(x: center.x - arrowSize / 2, y: center.y - arrowSize / 2, width: arrowSize, height: arrowSize)
        }
    }

    /// Tint colour of the arrow icon.
    @IBInspectable public var arrowColor: UIColor = .black {
        didSet {
            arrow.arrowColor = arrowColor
        }
    }
    /// Custom image used in place of the default triangle arrow. Set to `nil` to restore the default.
    @IBInspectable public var arrowImage: UIImage? {
        didSet {
            arrow.image = arrowImage
        }
    }
    
    /// Shows a check-mark accessory on the selected row when `true`.
    @IBInspectable public var checkMarkEnabled: Bool = true {
        didSet {
        }
    }

    /// When `true` the list repositions itself so it stays visible above the keyboard.
    @IBInspectable public var handleKeyboard: Bool = true {
        didSet {
        }
    }

    // Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        delegate = self
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupUI()
        delegate = self
    }

    // MARK: Closures

    fileprivate var didSelectCompletion: (String, Int, Int) -> Void = { _, _, _ in }
    fileprivate var TableWillAppearCompletion: () -> Void = { }
    fileprivate var TableDidAppearCompletion: () -> Void = { }
    fileprivate var TableWillDisappearCompletion: () -> Void = { }
    fileprivate var TableDidDisappearCompletion: () -> Void = { }

    func setupUI() {
        let size = frame.height
        let arrowView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size, height: size))
        let arrowContainerView = UIView(frame: arrowView.frame)
        if semanticContentAttribute == .forceRightToLeft {
            leftView = arrowView
            leftViewMode = .always
            leftView?.addSubview(arrowContainerView)
        } else {
            rightView = arrowView
            rightViewMode = .always
            rightView?.addSubview(arrowContainerView)
        }

        arrow = Arrow(origin: CGPoint(x: center.x - arrowSize / 2, y: center.y - arrowSize / 2), size: arrowSize)
        arrowContainerView.addSubview(arrow)

        backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = .clear
        addGesture()
        if isSearchEnable && handleKeyboard {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { notification in
                if self.isFirstResponder {
                    let userInfo: NSDictionary = notification.userInfo! as NSDictionary
                    let keyboardFrame: NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    self.keyboardHeight = keyboardRectangle.height
                    if !self.isSelected {
                        self.showList()
                    }
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { _ in
                if self.isFirstResponder {
                    self.keyboardHeight = 0
                }
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate func addGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(touchAction))
        if isSearchEnable {
            rightView?.addGestureRecognizer(gesture)
        } else {
            addGestureRecognizer(gesture)
        }
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(touchAction))
        backgroundView.addGestureRecognizer(gesture2)
    }



    public func showList() {
        guard let container = overlayContainer else { return }

        // Convert this field's origin into the coordinate space of the container (window).
        pointToParent = convert(bounds.origin, to: container)

        backgroundView.frame = container.bounds
        container.insertSubview(backgroundView, at: container.subviews.count)
        TableWillAppearCompletion()
        if listHeight > rowHeight * CGFloat(dataArray.count) {
            tableheightX = rowHeight * CGFloat(dataArray.count)
        } else {
            tableheightX = listHeight
        }
        let initialFrame = resolvedTableXAndWidth
        table = UITableView(frame: CGRect(x: initialFrame.x,
                                          y: pointToParent.y + frame.height,
                                          width: initialFrame.width,
                                          height: frame.height))
        shadow = UIView(frame: table.frame)
        shadow.backgroundColor = .clear

        table.dataSource = self
        table.delegate = self
        table.alpha = 0
        table.separatorStyle = .none
        table.layer.cornerRadius = 3
        table.backgroundColor = rowBackgroundColor
        table.rowHeight = rowHeight
        container.addSubview(shadow)
        container.addSubview(table)
        isSelected = true
        let containerHeight = container.frame.height
        let height = containerHeight - (pointToParent.y + frame.height + 5)
        var y = pointToParent.y + frame.height + 5
        if height < (keyboardHeight + tableheightX) {
            y = pointToParent.y - tableheightX
        }
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut,
                       animations: { () -> Void in

                           let showFrame = self.resolvedTableXAndWidth
                           self.table.frame = CGRect(x: showFrame.x,
                                                     y: y,
                                                     width: showFrame.width,
                                                     height: self.tableheightX)
                           self.table.alpha = 1
                           self.shadow.frame = self.table.frame
                           self.shadow.dropShadow()
                           self.arrow.position = .up

                       },
                       completion: { (_) -> Void in
                           self.layoutIfNeeded()

                       })
    }

    public func hideList() {
        TableWillDisappearCompletion()
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseIn,
                       animations: { () -> Void in
                           let hideFrame = self.resolvedTableXAndWidth
                           self.table.frame = CGRect(x: hideFrame.x,
                                                     y: self.pointToParent.y + self.frame.height,
                                                     width: hideFrame.width,
                                                     height: 0)
                           self.shadow.alpha = 0
                           self.shadow.frame = self.table.frame
                           self.arrow.position = .down
                       },
                       completion: { (_) -> Void in

                           self.shadow.removeFromSuperview()
                           self.table.removeFromSuperview()
                           self.backgroundView.removeFromSuperview()
                           self.isSelected = false
                           self.TableDidDisappearCompletion()
                       })
    }

    @objc public func touchAction() {
        isSelected ? hideList() : showList()
    }

    func reSizeTable() {
        guard let container = overlayContainer else { return }
        if listHeight > rowHeight * CGFloat(dataArray.count) {
            tableheightX = rowHeight * CGFloat(dataArray.count)
        } else {
            tableheightX = listHeight
        }
        let containerHeight = container.frame.height
        let height = containerHeight - (pointToParent.y + frame.height + 5)
        var y = pointToParent.y + frame.height + 5
        if height < (keyboardHeight + tableheightX) {
            y = pointToParent.y - tableheightX
        }
        UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                           let resizeFrame = self.resolvedTableXAndWidth
                           self.table.frame = CGRect(x: resizeFrame.x,
                                                     y: y,
                                                     width: resizeFrame.width,
                                                     height: self.tableheightX)
                           self.shadow.frame = self.table.frame
                           self.shadow.dropShadow()

                       },
                       completion: { (_) -> Void in
                           self.layoutIfNeeded()

                       })
    }

    // MARK: - Filter Methods

    /// Override this method to customise how the search text is matched against options.
    /// The default implementation performs a case-insensitive substring match.
    open func searchFilter(text: String, searchText: String) -> Bool {
        return text.range(of: searchText, options: .caseInsensitive) != nil
    }

    // MARK: - Callback registration

    /// Register a closure that fires whenever the user selects an option.
    /// - Parameters:
    ///   - completion: Receives the selected text, its index in `optionArray`,
    ///                 and the corresponding value from `optionIds` (or `0`).
    public func didSelect(completion: @escaping (_ selectedText: String, _ index: Int, _ id: Int) -> Void) {
        didSelectCompletion = completion
    }

    /// Called just before the dropdown list animates in.
    public func listWillAppear(completion: @escaping () -> Void) {
        TableWillAppearCompletion = completion
    }

    /// Called once the dropdown list is fully visible.
    public func listDidAppear(completion: @escaping () -> Void) {
        TableDidAppearCompletion = completion
    }

    /// Called just before the dropdown list animates out.
    public func listWillDisappear(completion: @escaping () -> Void) {
        TableWillDisappearCompletion = completion
    }

    /// Called once the dropdown list has been fully dismissed.
    public func listDidDisappear(completion: @escaping () -> Void) {
        TableDidDisappearCompletion = completion
    }

    /// Reloads the options list from the current `optionArray` on the main thread.
    public func reloadAllData() {
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
}

// MARK: UITextFieldDelegate

extension PDDropDown: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        superview?.endEditing(true)
        return false
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        // self.selectedIndex = nil
        dataArray = optionArray
        touchAction()
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isSearchEnable
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string != "" {
            searchText = text! + string
        } else {
            let subText = text?.dropLast()
            searchText = String(subText!)
        }
        if !isSelected {
            showList()
        }
        return true
    }
}

// MARK: UITableViewDataSource

extension PDDropDown: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DropDownCell"

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }

        if indexPath.row != selectedIndex {
            cell!.backgroundColor = rowBackgroundColor
        } else {
            cell?.backgroundColor = selectedRowColor
        }

        if imageArray.count > indexPath.row {
            cell!.imageView!.image = UIImage(named: imageArray[indexPath.row])
        }
        cell!.textLabel!.text = "\(dataArray[indexPath.row])"
        cell!.textLabel!.textColor = itemsColor
        cell!.tintColor = itemsTintColor
        cell!.accessoryType = (indexPath.row == selectedIndex) && checkMarkEnabled ? .checkmark : .none
        cell!.selectionStyle = .none
        cell?.textLabel?.font = font
        cell?.textLabel?.textAlignment = textAlignment
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = .byWordWrapping
        return cell!
    }
}

// MARK: UITableViewDelegate

extension PDDropDown: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = (indexPath as NSIndexPath).row
        let selectedText = dataArray[selectedIndex!]
        tableView.cellForRow(at: indexPath)?.alpha = 0
        UIView.animate(withDuration: 0.1,
                       animations: { () -> Void in
                           tableView.cellForRow(at: indexPath)?.alpha = 1.0
                           tableView.cellForRow(at: indexPath)?.backgroundColor = self.selectedRowColor
                       },
                       completion: { (_) -> Void in
                           self.text = "\(selectedText)"

                           tableView.reloadData()
                       })
        if hideOptionsWhenSelect {
            touchAction()
            endEditing(true)
        }
        if let selected = optionArray.firstIndex(where: { $0 == selectedText }) {
            if let id = optionIds?[selected] {
                didSelectCompletion(selectedText, selected, id)
            } else {
                didSelectCompletion(selectedText, selected, 0)
            }
        }
    }
}

// MARK: Arrow

enum Position {
    case left
    case down
    case right
    case up
}

class Arrow: UIView {
    let shapeLayer = CAShapeLayer()
    var arrowColor: UIColor = .black {
        didSet {
            shapeLayer.fillColor = arrowColor.cgColor
        }
    }
    var image: UIImage? {
        didSet {
            setUp()
        }
    }
    
    
    var imgView = UIImageView()
    var position: Position = .down {
        didSet {
            switch position {
            case .left:
                transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
                break

            case .down:
                transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
                break

            case .right:
                transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                break

            case .up:
                transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                break
            }
        }
    }

    init(origin: CGPoint, size: CGFloat) {
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: size, height: size))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        setUp()
    }
    func setUp() {

        if let img = image {
            shapeLayer.removeFromSuperlayer()

            imgView.image = img
            imgView.frame = bounds
            imgView.contentMode = .scaleAspectFit
            imgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            if imgView.superview == nil {
                addSubview(imgView)
            }
            return
        }

        imgView.removeFromSuperview()

        let size = bounds.width

        let bezierPath = UIBezierPath()
        let qSize = size / 4

        bezierPath.move(to: CGPoint(x: 0, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size / 2, y: qSize * 3))
        bezierPath.close()

        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = arrowColor.cgColor

        if shapeLayer.superlayer == nil {
            layer.addSublayer(shapeLayer)
        }
    }
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    func viewBorder(borderColor: UIColor, borderWidth: CGFloat?) {
        layer.borderColor = borderColor.cgColor
        if let borderWidth_ = borderWidth {
            layer.borderWidth = borderWidth_
        } else {
            layer.borderWidth = 1.0
        }
    }
}
