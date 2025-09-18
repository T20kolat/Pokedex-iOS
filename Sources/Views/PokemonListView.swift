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
						ProgressView("Loading Pokédex...")
							.font(.title3)
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
	
	var body: some View {
		NavigationLink(value: item.id) {
			HStack(spacing: 12) {
				PokemonImageView(url: item.artworkURL)
				VStack(alignment: .leading, spacing: 4) {
					Text(item.name)
						.font(.headline)
					Text(String(format: "#%03d", item.id))
						.font(.caption)
						.foregroundColor(.secondary)
				}
				Spacer()
			}
		}
		.scaleEffect(appearedIds.contains(item.id) ? 1.0 : 0.95)
		.opacity(appearedIds.contains(item.id) ? 1.0 : 0.0)
		.onAppear {
			withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
				appearedIds.insert(item.id)
			}
		}
	}
}

struct PokemonImageView: View {
	let url: URL?
	
	var body: some View {
		AsyncImage(url: url) { phase in
			switch phase {
			case .success(let image):
				image
					.resizable()
					.scaledToFit()
					.frame(width: 56, height: 56)
					.shadow(radius: 2)
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
}

struct PokemonListView_Previews: PreviewProvider {
	static var previews: some View {
		PokemonListView()
	}
}
