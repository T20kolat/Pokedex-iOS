import SwiftUI

struct TypeBadge: View {
	let type: String

	var body: some View {
		Text(type)
			.font(.caption.bold())
			.padding(.horizontal, 10)
			.padding(.vertical, 6)
			.background(Capsule().fill(color(for: type).opacity(0.2)))
			.foregroundColor(color(for: type).darker())
	}

	private func color(for type: String) -> Color {
		switch type.lowercased() {
		case "fire": return .orange
		case "water": return .blue
		case "grass": return .green
		case "electric": return .yellow
		case "poison": return .purple
		case "bug": return .green.opacity(0.7)
		case "flying": return .teal
		case "psychic": return .pink
		case "ice": return .cyan
		case "dragon": return .indigo
		case "dark": return .gray
		case "fairy": return .pink.opacity(0.8)
		case "rock": return .brown
		case "ground": return .orange.opacity(0.8)
		case "steel": return .gray.opacity(0.8)
		case "ghost": return .purple.opacity(0.6)
		case "fighting": return .red
		default: return .gray
		}
	}
}

private extension Color {
	func darker() -> Color { self.opacity(0.9) }
}

struct TypeBadge_Previews: PreviewProvider {
	static var previews: some View {
		TypeBadge(type: "Fire")
	}
}
