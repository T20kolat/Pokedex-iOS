import Foundation
import Combine

@MainActor
final class PokemonListViewModel: ObservableObject {
	@Published var all: [PokemonSummary] = []
	@Published var searchText: String = ""
	@Published var filtered: [PokemonSummary] = []
	@Published var isLoading = false
	@Published var errorMessage: String?

	private var cancellables = Set<AnyCancellable>()

	init() {
		$searchText
			.debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
			.removeDuplicates()
			.sink { [weak self] text in self?.applyFilter(text: text) }
			.store(in: &cancellables)
	}

	func load() async {
		guard all.isEmpty else { return }
		isLoading = true
		do {
			all = try await PokeAPIClient.shared.fetchPokemonList(limit: 1008) // All Pokémon through Gen 9
			filtered = all
			isLoading = false
		} catch {
			isLoading = false
			errorMessage = error.localizedDescription
		}
	}

	private func applyFilter(text: String) {
		let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { filtered = all; return }
		filtered = all.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
	}
}
