import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIButton {
    var backgroundColor: Binder<UIColor> {
        return Binder(self.base) { button, backgroundColor in
            button.backgroundColor = backgroundColor
        }
    }

    var isHighlighted: Observable<Bool> {
        return self.observe(Bool.self, "highlighted")
            .map { $0 == true }
    }
}
