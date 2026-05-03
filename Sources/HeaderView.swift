import SwiftUI

struct HeaderView: View {
    let isEmpty: Bool
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image("MenuBarIcon")
                .resizable()
                .renderingMode(.template)
                .frame(width: 16, height: 16)
                .foregroundStyle(Color.unmarkIndigo)

            Text("UNMARK")
                .font(.unmarkWordmark)
                .tracking(2.4)
                .foregroundStyle(Color.primary)

            Spacer()

            Button("Clear", action: onClear)
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isEmpty ? Color.secondary.opacity(0.4) : Color.unmarkIndigo)
                .disabled(isEmpty)
                .animation(.easeInOut(duration: 0.15), value: isEmpty)
        }
    }
}
