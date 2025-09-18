import Foundation

final class PokeAPIClient {
	static let shared = PokeAPIClient()
	private init() {}

	private let baseURL = URL(string: "https://pokeapi.co/api/v2")!
	private let session: URLSession = {
		let config = URLSessionConfiguration.default
		config.requestCachePolicy = .returnCacheDataElseLoad
		config.urlCache = URLCache(memoryCapacity: 50_000_000, diskCapacity: 200_000_000)
		return URLSession(configuration: config)
	}()

	func fetchPokemonList(limit: Int = 151, offset: Int = 0) async throws -> [PokemonSummary] {
		let url = baseURL.appendingPathComponent("pokemon").appending(queryItems: [
			URLQueryItem(name: "limit", value: String(limit)),
			URLQueryItem(name: "offset", value: String(offset))
		])
		let (data, _) = try await session.data(from: url)
		let decoded = try JSONDecoder().decode(PokemonListResponse.self, from: data)
		return decoded.results.compactMap { res in
			guard let id = res.url.split(separator: "/").compactMap({ Int($0) }).last else { return nil }
			return PokemonSummary(id: id, name: res.name.capitalized, artworkURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"))
		}.sorted { $0.id < $1.id }
	}

	func fetchPokemonDetail(id: Int) async throws -> PokemonDetail {
		let pokemonURL = baseURL.appendingPathComponent("pokemon/\(id)")
		let (pokemonData, _) = try await session.data(from: pokemonURL)
		let pokemon = try JSONDecoder().decode(Pokemon.self, from: pokemonData)

		let speciesURL = baseURL.appendingPathComponent("pokemon-species/\(id)")
		let (speciesData, _) = try await session.data(from: speciesURL)
		let species = try JSONDecoder().decode(PokemonSpecies.self, from: speciesData)

		let description = species.flavor_text_entries.first(where: { $0.language.name == "en" })?.flavor_text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\u{0C}", with: " ") ?? ""

		let evoURL = URL(string: species.evolution_chain.url)!
		let (evoData, _) = try await session.data(from: evoURL)
		let evo = try JSONDecoder().decode(EvolutionChain.self, from: evoData)
		let chain = flattenEvolution(chain: evo.chain)

		let types = pokemon.types.sorted { $0.slot < $1.slot }.map { $0.type.name.capitalized }
		let abilities = pokemon.abilities.sorted { $0.slot < $1.slot }
		let regularAbilities = abilities.filter { !$0.is_hidden }.map { $0.ability.name.capitalized }
		let hiddenAbility = abilities.first(where: { $0.is_hidden })?.ability.name.capitalized
		let stats = pokemon.stats.map { ($0.stat.name.uppercased().replacingOccurrences(of: "-", with: " "), $0.base_stat) }

		return PokemonDetail(
			id: pokemon.id,
			name: pokemon.displayName,
			numberText: String(format: "#%03d", pokemon.id),
			artworkURL: pokemon.artworkURL,
			types: types,
			description: description,
			heightText: String(format: "%.1f m", Double(pokemon.height) / 10.0),
			weightText: String(format: "%.1f kg", Double(pokemon.weight) / 10.0),
			stats: stats,
			abilities: regularAbilities,
			hiddenAbility: hiddenAbility,
			evolutionChain: chain
		)
	}

	private func flattenEvolution(chain: ChainLink) -> [PokemonSummary] {
		var result: [PokemonSummary] = []
		func traverse(_ node: ChainLink) {
			if let id = node.species.url.split(separator: "/").compactMap({ Int($0) }).last {
				let summary = PokemonSummary(id: id, name: node.species.name.capitalized, artworkURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"))
				result.append(summary)
			}
			node.evolves_to.forEach { traverse($0) }
		}
		traverse(chain)
		return result
	}
}

private extension URL {
	func appending(queryItems: [URLQueryItem]) -> URL {
		guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
		components.queryItems = (components.queryItems ?? []) + queryItems
		return components.url ?? self
	}
}
