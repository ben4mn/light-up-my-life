import SwiftUI

// MARK: - Colors

extension Color {
    static let accentAmber = Color(red: 0.95, green: 0.68, blue: 0.15)
    static let accentAmberDark = Color(red: 0.85, green: 0.55, blue: 0.10)
}

// MARK: - Amber Toggle Style

struct AmberToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()

            ZStack {
                // Track
                Capsule()
                    .fill(configuration.isOn ? Color.accentAmber : Color.gray.opacity(0.3))
                    .frame(width: 44, height: 26)

                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 22, height: 22)
                    .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                    .offset(x: configuration.isOn ? 9 : -9)
            }
            .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            .onTapGesture {
                configuration.isOn.toggle()
            }

            configuration.label
                .padding(.leading, 6)

            Spacer()
        }
    }
}
