import SwiftUI

struct CopyFeedbackView: View {
    @State private var trim: CGFloat = 0
    @State private var pulse: CGFloat = 0.6

    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(Color.unmarkAmber.opacity(0.15))
                    .frame(width: 18, height: 18)
                    .scaleEffect(pulse)

                checkmarkPath
                    .trim(from: 0, to: trim)
                    .stroke(
                        Color.unmarkAmber,
                        style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: 14, height: 14)
            }

            Text("Copied")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.unmarkAmber)
                .tracking(0.4)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.32)) {
                trim = 1
            }
            withAnimation(.easeOut(duration: 0.45)) {
                pulse = 1.15
            }
        }
    }

    private var checkmarkPath: Path {
        Path { p in
            p.move(to: CGPoint(x: 2.5, y: 7.5))
            p.addLine(to: CGPoint(x: 6, y: 10.5))
            p.addLine(to: CGPoint(x: 11.5, y: 4))
        }
    }
}
