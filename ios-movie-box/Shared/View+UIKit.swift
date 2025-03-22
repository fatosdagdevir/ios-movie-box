import SwiftUI
import UIKit

extension View {
    func hosted() -> UIHostingController<Self> {
        let hosting = UIHostingController(rootView: self)
        return hosting
    }
}

extension UIViewController {
    func asHosted<T>(_ type: T.Type) -> UIHostingController<T>? {
        self as? UIHostingController<T>
    }
}
