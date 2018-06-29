import RxCocoa
import RxSwift
import UIKit

@IBDesignable
class DefaultButton: UIView {

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var bottomShadow: UIImageView!

    @IBOutlet weak var button: UIButton!

    @IBInspectable var text: String = "" {
        didSet {
            button.setTitle(text, for: .normal)
        }
    }

    @IBInspectable var accessibilityIdButton: String = "" {
        didSet {
            button.accessibilityIdentifier = accessibilityIdButton
        }
    }

    @IBInspectable var isButtonEnabled: Bool = false {
        didSet {
            isEnabled.value = isButtonEnabled
        }
    }

    let isEnabled: Variable<Bool> = Variable(false)

    let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }

    private func setup() {
        xibSetup()

        #if !TARGET_INTERFACE_BUILDER
        buttonSetup()
        backgroundColorBinding()
        bottomShadowBinding()
        #endif
    }

    private func xibSetup() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DefaultButton", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }

        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
    }

    private func buttonSetup() {
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 3
        button.titleLabel?.adjustsFontSizeToFitWidth = false
    }

    private func backgroundColorBinding() {
        isEnabled.asObservable().bind(to: button.rx.isEnabled).disposed(by: disposeBag)
        isEnabled.asObservable()
            .map { return $0 ? UIColor.magenta: UIColor.gray }
            .bind(to: button.rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    private func bottomShadowBinding() {
        // shadow is visible if button is enabled && button is not highlighted

        Observable.combineLatest(
            button.rx.isHighlighted,
            isEnabled.asObservable()) { isHighlighted, isEnabled in
                return isHighlighted || !isEnabled
            }.bind(to: bottomShadow.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
