import SwiftUI

/// this implementation is copied from somewhere!!
public extension View {
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(FirstAppear(action: action))
    }

    func onFirstAppear(_ action: @escaping () async -> Void) -> some View {
        modifier(FirstAsyncAppear(action: action))
    }
}

private struct FirstAppear: ViewModifier {
    let action: () -> Void

    // Use this to only fire your block one time
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        // And then, track it here
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}

private struct FirstAsyncAppear: ViewModifier {
    let action: () async -> Void

    // Use this to only fire your block one time
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        // And then, track it here
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            Task {
                await action()
            }
        }
    }
}
