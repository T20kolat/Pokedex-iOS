import Foundation

@MainActor
final class PokemonDetailViewModel: ObservableObject {
	@Published var detail: PokemonDetail?
	@Published var isLoading = false
	@Published var errorMessage: String?

	let id: Int
	init(id: Int) { self.id = id }

	func load() async {
		guard detail == nil else { return }
		isLoading = true
		do {
			detail = try await PokeAPIClient.shared.fetchPokemonDetail(id: id)
			isLoading = false
		} catch {
			isLoading = false
			errorMessage = error.localizedDescription
		}
	}
}
