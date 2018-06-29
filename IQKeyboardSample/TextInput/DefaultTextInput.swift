import RxCocoa
import RxSwift
import UIKit

@IBDesignable
class DefaultTextInput: UIView {
    @IBOutlet weak var textField: UITextField! { didSet {
        textField.layer.borderColor = UIColor.cloudyBlue.cgColor
        textField.layer.borderWidth = 1
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 3
        textField.addPadding(.both(19))
    }}

    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!

    @IBOutlet weak private var wrongFormatLabel: PaddingLabel! { didSet {
        wrongFormatLabel.accessibilityIdentifier = "inputErrorMessage"
    }}
    @IBOutlet weak var bottomShadow: UIImageView!

    @IBInspectable var accessibilityLabelComponent: String = "" {
        didSet {
            titleLabel.accessibilityIdentifier = accessibilityLabelComponent + "Title"
            textField.accessibilityIdentifier = accessibilityLabelComponent + "Input"
        }
    }

    @IBInspectable var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    @IBInspectable var text: String = "" {
        didSet {
            textField.text = text
        }
    }

    @IBInspectable var placeholder: String = "" {
        didSet {
            textField.attributedPlaceholder =
                NSAttributedString(string: placeholder,
                                   attributes: [NSAttributedStringKey.foregroundColor: placeholderColor])
        }
    }

    @IBInspectable var placeholderColor: UIColor = UIColor.cloudyBlue {
        didSet {
            textField.attributedPlaceholder =
                NSAttributedString(string: placeholder,
                                   attributes: [NSAttributedStringKey.foregroundColor: placeholderColor])
        }
    }

    @IBInspectable var wrongFormatText: String = ""
    @IBInspectable var secureTextEntry: Bool = false { didSet {
        textField.isSecureTextEntry = secureTextEntry
    }}

    //If true first validation message will trigger after didEndEditing
    var isFirstRunValidation: Variable<Bool> = Variable(true)

    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }

    let validation = DefaultInputFormatValidation()

    let isValid = Variable<Bool>(false) //By default we consider field as invalid
    let isValidationLabelVisible = Variable<Bool>(false) //By default validation message is invisible

    let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        xibSetup()

        #if !TARGET_INTERFACE_BUILDER
        shadowBindings()

        isFirstRunValidation
            .asObservable()
            .subscribe { [weak self] firstRunActive in
                if firstRunActive.element == true {
                    self?.firstValidationBindings()
                } else {
                    self?.validationLabelBindings()
                }
            }
            .disposed(by: disposeBag)
        #endif
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }

    private func xibSetup() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DefaultTextInput", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }

        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth]
        addSubview(view)
        contentView = view
    }

    private func shadowBindings() {
        // By Default we present shadow when editing is in progress
        let isEditing = textField.rx.controlEvent([.editingDidBegin, .editingDidEnd])
            .map { [weak self] _ -> Bool in
                let isTextFieldActive = self?.textField.isFirstResponder ?? false
                return isTextFieldActive
            }.asObservable()

        // Display shadow if textInpit is currently being edited and validation form is hidden
        Observable.combineLatest(isEditing, isValidationLabelVisible.asObservable()) { isEditing, isValidationVisible in
            return !(isEditing && !isValidationVisible)
        }
        .bind(to: bottomShadow.rx.isHidden)
        .disposed(by: disposeBag)
    }

    private func firstValidationBindings() {
        // All editing events are triggering validation
        textField.rx.controlEvent([.editingChanged, .editingDidEnd, .editingDidEndOnExit])
            .map { [weak self] _ -> Bool in
                return self?.validation.isValid(input: self?.textField.text) == true
            }
            .bind(to: isValid)
            .disposed(by: disposeBag)

        // When editing is done we're binding labelFormat. This prevents showing error label on first edit
        textField.rx.controlEvent(.editingDidEnd)
            .take(1)
            .subscribe(onNext: { [weak self] in
                self?.isFirstRunValidation.value = false
            })
            .disposed(by: disposeBag)

        // All editingDidEnd triggers frame color change
        textField.rx.controlEvent(.editingDidEnd)
            .map({ [weak self] _ -> CGColor in
                return (self?.isValid.value == false) ? UIColor.darkHotPink.cgColor : UIColor.cloudyBlue.cgColor
            })
            .subscribe(onNext: { [weak self] textFieldBorderColor in
                self?.textField.layer.borderColor = textFieldBorderColor
            })
            .disposed(by: disposeBag)
    }

    private func validationLabelBindings() {
        // If field is invalid and validation text is present we can display validation label
        isValid.asObservable()
            .map({ [weak self] isValid -> Bool in
                return !isValid && self?.wrongFormatText.isEmpty == false
            })
            .bind(to: isValidationLabelVisible)
            .disposed(by: disposeBag)

        // If validation label is Visible, draw label + change frame color
        isValidationLabelVisible.asObservable()
            .do(onNext: { [weak self] isVisible in
                self?.wrongFormatLabel.text = self?.wrongFormatText
                self?.wrongFormatLabel.isHidden = !isVisible
            })
            .map({ isVisible -> CGColor in
                return (isVisible) ? UIColor.darkHotPink.cgColor : UIColor.cloudyBlue.cgColor
            })
            .subscribe(onNext: { [weak self] textFieldBorderColor in
                self?.textField.layer.borderColor = textFieldBorderColor
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public Section
extension DefaultTextInput {
    func forceValidationMessage(_ message: String) {
        isFirstRunValidation.value = false
        isValidationLabelVisible.value = true
        wrongFormatLabel.text = message
    }

    func forceDismissValidationMessage() {
        isValidationLabelVisible.value = false
    }
}
