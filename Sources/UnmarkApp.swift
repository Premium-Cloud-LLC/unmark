import SwiftUI

@main
struct UnmarkApp: App {
    var body: some Scene {
        MenuBarExtra("Unmark", image: "MenuBarIcon") {
            ConverterView()
        }
        .menuBarExtraStyle(.window)

        Window("About Unmark", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
