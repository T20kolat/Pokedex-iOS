import SwiftUI

struct PokemonListView: View {
	@StateObject private var vm = PokemonListViewModel()
	@State private var appearedIds: Set<Int> = []
	@Namespace private var ns

	var body: some View {
		ZStack {
			PlayfulBackground()
			.opacity(0.6)
			.blur(radius: 6)
			NavigationStack {
				Group {
				if vm.isLoading {
					VStack(spacing: 16) {
						ProgressView()
							.scaleEffect(1.5)
						Text("Loading Pokédex...")
							.font(.title3)
						Text("Catching all \(vm.all.count > 0 ? "\(vm.all.count)" : "1000+") Pokémon!")
							.font(.caption)
							.foregroundColor(.secondary)
					}
					} else if let error = vm.errorMessage {
						VStack(spacing: 12) {
							Text("Oops! \(error)")
							Button("Retry") { Task { await vm.load() } }
						}
					} else {
						List {
							ForEach(vm.filtered) { item in
								PokemonRowView(
									item: item,
									appearedIds: $appearedIds
								)
							}
						}
						.listStyle(.plain)
					}
				}
				.navigationTitle("Pokédex")
				.searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Pokémon")
				.navigationDestination(for: Int.self) { id in
					PokemonDetailView(id: id)
				}
			}
		}
		.task { await vm.load() }
	}
}

struct PokemonRowView: View {
	let item: PokemonSummary
	@Binding var appearedIds: Set<Int>
	@State private var showGlow = false
	
	var body: some View {
		NavigationLink(value: item.id) {
			HStack(spacing: 12) {
				PokemonImageView(url: item.artworkURL, rarity: item.rarity)
				VStack(alignment: .leading, spacing: 4) {
					HStack {
						Text(item.name)
							.font(.headline)
							.foregroundColor(rarityTextColor)
						Spacer()
						RarityBadge(rarity: item.rarity)
					}
					Text(String(format: "#%03d", item.id))
						.font(.caption)
						.foregroundColor(.secondary)
				}
				Spacer()
			}
			.padding(.vertical, 4)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(rarityBackgroundColor.opacity(0.1))
					.overlay(
						RoundedRectangle(cornerRadius: 12)
							.stroke(rarityBorderColor, lineWidth: showGlow ? 2 : 1)
					)
			)
		}
		.scaleEffect(appearedIds.contains(item.id) ? 1.0 : 0.95)
		.opacity(appearedIds.contains(item.id) ? 1.0 : 0.0)
		.onAppear {
			withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
				_ = appearedIds.insert(item.id)
			}
			if item.rarity == .legendary || item.rarity == .mythical {
				withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
					showGlow = true
				}
			}
		}
	}
	
	private var rarityTextColor: Color {
		switch item.rarity {
		case .common: return .primary
		case .uncommon: return .green
		case .rare: return .blue
		case .epic: return .purple
		case .legendary: return .orange
		case .mythical: return .pink
		}
	}
	
	private var rarityBackgroundColor: Color {
		switch item.rarity {
		case .common: return .gray
		case .uncommon: return .green
		case .rare: return .blue
		case .epic: return .purple
		case .legendary: return .orange
		case .mythical: return .pink
		}
	}
	
	private var rarityBorderColor: Color {
		switch item.rarity {
		case .common: return .gray.opacity(0.3)
		case .uncommon: return .green.opacity(0.5)
		case .rare: return .blue.opacity(0.5)
		case .epic: return .purple.opacity(0.5)
		case .legendary: return .orange.opacity(0.7)
		case .mythical: return .pink.opacity(0.7)
		}
	}
}

struct PokemonImageView: View {
	let url: URL?
	let rarity: PokemonRarity
	@State private var pulse = false
	
	var body: some View {
		ZStack {
			// Glow effect for legendary/mythical
			if rarity == .legendary || rarity == .mythical {
				Circle()
					.fill(rarityGlowColor.opacity(0.3))
					.frame(width: 70, height: 70)
					.scaleEffect(pulse ? 1.2 : 1.0)
					.animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
			}
			
			AsyncImage(url: url) { phase in
				switch phase {
				case .success(let image):
					image
						.resizable()
						.scaledToFit()
						.frame(width: 56, height: 56)
						.shadow(color: rarityShadowColor, radius: rarity == .legendary || rarity == .mythical ? 6 : 2)
						.overlay(
							RoundedRectangle(cornerRadius: 8)
								.stroke(rarityBorderColor, lineWidth: rarity == .legendary || rarity == .mythical ? 2 : 0)
						)
				case .failure(_):
					Image(systemName: "questionmark.circle")
						.frame(width: 56, height: 56)
						.foregroundColor(.gray)
				case .empty:
					ProgressView()
						.frame(width: 56, height: 56)
				@unknown default:
					EmptyView()
				}
			}
		}
		.onAppear {
			if rarity == .legendary || rarity == .mythical {
				pulse = true
			}
		}
	}
	
	private var rarityGlowColor: Color {
		switch rarity {
		case .legendary: return .orange
		case .mythical: return .pink
		default: return .clear
		}
	}
	
	private var rarityShadowColor: Color {
		switch rarity {
		case .common: return .black.opacity(0.2)
		case .uncommon: return .green.opacity(0.3)
		case .rare: return .blue.opacity(0.3)
		case .epic: return .purple.opacity(0.3)
		case .legendary: return .orange.opacity(0.5)
		case .mythical: return .pink.opacity(0.5)
		}
	}
	
	private var rarityBorderColor: Color {
		switch rarity {
		case .legendary: return .orange
		case .mythical: return .pink
		default: return .clear
		}
	}
}

struct PokemonListView_Previews: PreviewProvider {
	static var previews: some View {
		PokemonListView()
	}
}
