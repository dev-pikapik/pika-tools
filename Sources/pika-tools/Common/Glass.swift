import SwiftUI

extension View {
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat = 14) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        #if compiler(>=6.2)
        if #available(macOS 26, *) {
            glassEffect(.regular, in: shape)
        } else {
            materialCard(shape)
        }
        #else
        materialCard(shape)
        #endif
    }

    @ViewBuilder
    func glassButtons() -> some View {
        #if compiler(>=6.2)
        if #available(macOS 26, *) {
            buttonStyle(.glass)
        } else {
            buttonStyle(.bordered)
        }
        #else
        buttonStyle(.bordered)
        #endif
    }

    private func materialCard(_ shape: RoundedRectangle) -> some View {
        background(.regularMaterial, in: shape)
            .overlay(shape.strokeBorder(Color(nsColor: .separatorColor).opacity(0.6), lineWidth: 0.5))
    }
}
