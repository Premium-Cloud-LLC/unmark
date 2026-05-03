import SwiftUI
import AppKit

struct ConverterView: View {
    @Environment(\.openWindow) private var openWindow

    @AppStorage("outputFormat") private var formatRaw: String = OutputFormat.richText.rawValue

    @State private var markdown: String = ""
    @State private var showCopiedAlert: Bool = false
    @State private var clearProgress: Double = 0
    @State private var hasAppeared: Bool = false

    @State private var feedbackTask: Task<Void, Never>?
    @State private var debounceTask: Task<Void, Never>?
    @State private var autoClearTask: Task<Void, Never>?

    private let converter = MarkdownConverter()
    private let clipboard = ClipboardManager()

    private var format: OutputFormat {
        OutputFormat(rawValue: formatRaw) ?? .richText
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HeaderView(isEmpty: markdown.isEmpty, onClear: clearAll)
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : -6)
                .animation(.easeOut(duration: 0.30), value: hasAppeared)

            editorBlock
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 6)
                .animation(.easeOut(duration: 0.32).delay(0.04), value: hasAppeared)

            HStack(spacing: 10) {
                FormatSelector(formatRaw: $formatRaw)
                    .onChange(of: formatRaw) { _ in
                        if !markdown.isEmpty {
                            scheduleConversion(for: markdown)
                        }
                    }

                Spacer()

                if showCopiedAlert {
                    CopyFeedbackView()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity
                        ))
                }
            }
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 6)
            .animation(.easeOut(duration: 0.32).delay(0.08), value: hasAppeared)

            footerActions
                .opacity(hasAppeared ? 1 : 0)
                .animation(.easeOut(duration: 0.32).delay(0.12), value: hasAppeared)
        }
        .padding(14)
        .frame(width: 400, height: 360)
        .background(popoverBackground)
        .onAppear {
            withAnimation { hasAppeared = true }
        }
    }

    private var editorBlock: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $markdown)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.textBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            showCopiedAlert ? Color.unmarkAmber.opacity(0.55) : Color(NSColor.separatorColor),
                            lineWidth: 1
                        )
                        .animation(.easeOut(duration: 0.25), value: showCopiedAlert)
                )
                .overlay(alignment: .bottom) {
                    autoClearBar
                }
                .onChange(of: markdown) { newValue in
                    scheduleConversion(for: newValue)
                }

            if markdown.isEmpty {
                EmptyStateView()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private var autoClearBar: some View {
        if clearProgress > 0 && clearProgress < 1 {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    LinearGradient(
                        colors: [Color.unmarkIndigo, Color.unmarkAmber],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: max(0, geo.size.width * (1 - clearProgress)))

                    Spacer(minLength: 0)
                }
            }
            .frame(height: 1.5)
            .clipShape(RoundedRectangle(cornerRadius: 1))
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
            .transition(.opacity)
        }
    }

    private var footerActions: some View {
        HStack(spacing: 14) {
            Spacer()

            Button {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "about")
            } label: {
                Text("About")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)

            HStack(spacing: 5) {
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)
                .keyboardShortcut("q", modifiers: .command)

                KeyboardHint(label: "⌘Q")
            }
        }
    }

    private var popoverBackground: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
            LinearGradient(
                colors: [
                    Color.unmarkIndigo.opacity(0.04),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Behavior

    private func scheduleConversion(for text: String) {
        debounceTask?.cancel()
        autoClearTask?.cancel()
        if clearProgress > 0 {
            withAnimation(.easeOut(duration: 0.18)) {
                clearProgress = 0
            }
        }

        guard !text.isEmpty else { return }

        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000)
            guard !Task.isCancelled else { return }

            let attributed = converter.toAttributedString(text)
            clipboard.copy(attributed: attributed, format: format)
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
            showCopiedFeedback()
            scheduleAutoClear()
        }
    }

    private func scheduleAutoClear() {
        autoClearTask?.cancel()

        clearProgress = 0
        withAnimation(.linear(duration: 5.0)) {
            clearProgress = 1.0
        }

        autoClearTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                markdown = ""
                clearProgress = 0
            }
        }
    }

    private func clearAll() {
        debounceTask?.cancel()
        autoClearTask?.cancel()
        feedbackTask?.cancel()
        withAnimation(.easeOut(duration: 0.2)) {
            clearProgress = 0
            markdown = ""
            showCopiedAlert = false
        }
    }

    private func showCopiedFeedback() {
        feedbackTask?.cancel()
        withAnimation(.easeOut(duration: 0.22)) {
            showCopiedAlert = true
        }
        feedbackTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.35)) {
                showCopiedAlert = false
            }
        }
    }
}
