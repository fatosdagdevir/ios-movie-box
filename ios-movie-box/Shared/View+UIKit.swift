import SwiftUI
import UIKit

extension View {
    func hosted() -> UIHostingController<Self> {
        let hosting = UIHostingController(rootView: self)
        return hosting
    }
}
