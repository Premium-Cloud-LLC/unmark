import SwiftUI
import AppKit

struct AboutView: View {
    @State private var launchAtLogin: Bool = LaunchAtLogin.isEnabled
    @State private var hasAppeared: Bool = false

    private var version: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0"
    }

    private var build: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "1"
    }

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 22) {
                Spacer().frame(height: 4)

                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 124, height: 124)
                    .shadow(color: Color.unmarkIndigo.opacity(0.45), radius: 22, y: 8)
                    .scaleEffect(hasAppeared ? 1 : 0.86)
                    .opacity(hasAppeared ? 1 : 0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.78), value: hasAppeared)

                VStack(spacing: 6) {
                    Text("UNMARK")
                        .font(.unmarkWordmarkLarge)
                        .tracking(7.5)
                        .foregroundStyle(Color.primary)

                    Text("Markdown, perfectly pasted.")
                        .font(.unmarkTagline)
                        .foregroundStyle(.secondary)
                }
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 6)
                .animation(.easeOut(duration: 0.4).delay(0.08), value: hasAppeared)

                Rectangle()
                    .fill(Color.unmarkIndigo.opacity(0.25))
                    .frame(width: 36, height: 1)
                    .opacity(hasAppeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.15), value: hasAppeared)

                HStack {
                    Text("Launch at login")
                        .font(.system(size: 13))
                        .foregroundStyle(.primary)

                    Spacer()

                    Toggle("", isOn: $launchAtLogin)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .tint(Color.unmarkIndigo)
                        .onChange(of: launchAtLogin) { newValue in
                            if !LaunchAtLogin.set(newValue) {
                                launchAtLogin = LaunchAtLogin.isEnabled
                            }
                        }
                }
                .padding(.horizontal, 44)
                .opacity(hasAppeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.18), value: hasAppeared)

                Spacer()

                VStack(spacing: 6) {
                    Text("Version \(version) (Build \(build))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .tracking(0.2)

                    HStack(spacing: 4) {
                        Text("Made with")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Color.unmarkAmber)
                        Text("for the Markdown era")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.bottom, 22)
                .opacity(hasAppeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.22), value: hasAppeared)
            }
            .padding(.top, 28)
        }
        .frame(width: 360, height: 460)
        .onAppear {
            hasAppeared = true
        }
    }

    private var backgroundGradient: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)

            LinearGradient(
                colors: [
                    Color.unmarkIndigo.opacity(0.18),
                    Color.unmarkIndigo.opacity(0.04),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )

            RadialGradient(
                colors: [Color.unmarkAmber.opacity(0.08), Color.clear],
                center: .bottom,
                startRadius: 10,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
    }
}
