import SwiftUI

struct FormatSelector: View {
    @Binding var formatRaw: String
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 0) {
            ForEach(OutputFormat.allCases) { format in
                segment(for: format)
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.10), lineWidth: 0.5)
        )
    }

    private func segment(for format: OutputFormat) -> some View {
        let isSelected = formatRaw == format.rawValue

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                formatRaw = format.rawValue
            }
        } label: {
            Text(format.rawValue)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .padding(.horizontal, 11)
                .padding(.vertical, 5)
                .background(
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.unmarkIndigo)
                                .shadow(color: Color.unmarkIndigo.opacity(0.35), radius: 4, y: 1)
                                .matchedGeometryEffect(id: "selection", in: ns)
                        }
                    }
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
