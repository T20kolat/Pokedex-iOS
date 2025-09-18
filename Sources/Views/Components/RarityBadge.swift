import SwiftUI

struct RarityBadge: View {
	let rarity: PokemonRarity
	@State private var animate = false
	
	var body: some View {
		Text(rarity.rawValue)
			.font(.caption2.bold())
			.padding(.horizontal, 8)
			.padding(.vertical, 4)
			.background(
				Capsule()
					.fill(rarityColor.opacity(0.2))
					.overlay(
						Capsule()
							.stroke(rarityColor, lineWidth: 1)
					)
			)
			.foregroundColor(rarityColor)
			.shadow(color: rarityColor.opacity(0.3), radius: animate ? 4 : 2, x: 0, y: 0)
			.scaleEffect(animate ? 1.05 : 1.0)
			.onAppear {
				if rarity == .legendary || rarity == .mythical {
					withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
						animate = true
					}
				}
			}
	}
	
	private var rarityColor: Color {
		switch rarity {
		case .common: return .gray
		case .uncommon: return .green
		case .rare: return .blue
		case .epic: return .purple
		case .legendary: return .orange
		case .mythical: return .pink
		}
	}
}

struct RarityBadge_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 8) {
			RarityBadge(rarity: .common)
			RarityBadge(rarity: .uncommon)
			RarityBadge(rarity: .rare)
			RarityBadge(rarity: .epic)
			RarityBadge(rarity: .legendary)
			RarityBadge(rarity: .mythical)
		}
		.padding()
	}
}
