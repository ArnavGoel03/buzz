import SwiftUI

/// SwiftUI modifiers whose APIs only exist on iOS / iPadOS get conditionally applied here.
/// On macOS we no-op them, so calling sites stay clean — no `#if os` ladders inside views.
extension View {
    @ViewBuilder
    func iosOnlyHideStatusBar() -> some View {
        #if os(iOS)
        self.statusBarHidden(true)
        #else
        self
        #endif
    }

    @ViewBuilder
    func iosOnlyHidePersistentOverlays() -> some View {
        #if os(iOS)
        self.persistentSystemOverlays(.hidden)
        #else
        self
        #endif
    }

    @ViewBuilder
    func iosNavigationInline() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func iosHideNavigationBackground() -> some View {
        #if os(iOS)
        self.toolbarBackground(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }

    @ViewBuilder
    func iosNumericKeyboard() -> some View {
        #if os(iOS)
        self.keyboardType(.numberPad)
        #else
        self
        #endif
    }

    @ViewBuilder
    func iosDragIndicator() -> some View {
        #if os(iOS)
        self.presentationDragIndicator(.visible)
        #else
        self
        #endif
    }

    /// `textInputAutocapitalization` is iOS-only. These helpers apply it on iOS,
    /// no-op on macOS.
    @ViewBuilder
    func iosLowercaseInput() -> some View {
        #if os(iOS)
        self.textInputAutocapitalization(.never).autocorrectionDisabled()
        #else
        self.autocorrectionDisabled()
        #endif
    }

    @ViewBuilder
    func iosUppercaseInput() -> some View {
        #if os(iOS)
        self.textInputAutocapitalization(.characters).autocorrectionDisabled()
        #else
        self.autocorrectionDisabled()
        #endif
    }

    /// `fullScreenCover` is iOS-only. On macOS we fall back to `sheet` (opens as a modal
    /// window — the correct macOS equivalent of a takeover view).
    @ViewBuilder
    func fullCover<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if os(iOS)
        self.fullScreenCover(isPresented: isPresented, content: content)
        #else
        self.sheet(isPresented: isPresented, content: content)
        #endif
    }

    /// `.searchable(..., placement: .navigationBarDrawer(...))` is iOS-only. On macOS
    /// we use the default placement (toolbar).
    @ViewBuilder
    func iosSearchableAlwaysVisible(text: Binding<String>, prompt: String) -> some View {
        #if os(iOS)
        self.searchable(
            text: text,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: prompt
        )
        #else
        self.searchable(text: text, prompt: prompt)
        #endif
    }
}
