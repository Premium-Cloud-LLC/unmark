import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Paste your Markdown")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Rectangle()
                    .fill(Color.unmarkIndigo.opacity(0.45))
                    .frame(width: 28, height: 1.5)
            }

            VStack(alignment: .leading, spacing: 9) {
                row(raw: "# Heading",  rendered: "Heading", style: .system(size: 13, weight: .bold))
                row(raw: "**bold**",   rendered: "bold",    style: .system(size: 13, weight: .bold))
                row(raw: "- Item",     rendered: "• Item",  style: .system(size: 13))
            }

            HStack(spacing: 5) {
                Text("⌘V")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary.opacity(0.14))
                    )
                Text("to paste")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private func row(raw: String, rendered: String, style: Font) -> some View {
        HStack(spacing: 10) {
            Text(raw)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.secondary.opacity(0.65))
                .frame(width: 84, alignment: .leading)

            Image(systemName: "arrow.right")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.unmarkIndigo.opacity(0.6))

            Text(rendered)
                .font(style)
                .foregroundStyle(Color.primary.opacity(0.85))

            Spacer()
        }
    }
}
