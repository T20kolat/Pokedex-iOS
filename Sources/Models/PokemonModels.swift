import Foundation

// MARK: - Paginated list
struct PokemonListResponse: Codable {
	let count: Int
	let next: String?
	let previous: String?
	let results: [NamedAPIResource]
}

struct NamedAPIResource: Codable, Identifiable {
	let name: String
	let url: String
	var id: String { name }
}

// MARK: - Pokemon
struct Pokemon: Codable, Identifiable {
	let id: Int
	let name: String
	let height: Int
	let weight: Int
	let types: [PokemonTypeSlot]
	let stats: [PokemonStat]
	let abilities: [PokemonAbility]

	var displayName: String { name.capitalized }
	var artworkURL: URL? {
		URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
	}
}

struct PokemonTypeSlot: Codable {
	let slot: Int
	let type: NamedAPIResource
}

struct PokemonStat: Codable, Identifiable {
	let base_stat: Int
	let effort: Int
	let stat: NamedAPIResource
	var id: String { stat.name }
}

struct PokemonAbility: Codable, Identifiable {
	let is_hidden: Bool
	let slot: Int
	let ability: NamedAPIResource
	var id: String { ability.name }
}

// MARK: - Species
struct PokemonSpecies: Codable {
	let flavor_text_entries: [FlavorText]
	let evolution_chain: APIResource
}

struct FlavorText: Codable {
	let flavor_text: String
	let language: NamedAPIResource
}

struct APIResource: Codable { let url: String }

// MARK: - Evolution Chain
struct EvolutionChain: Codable {
	let id: Int
	let chain: ChainLink
}

struct ChainLink: Codable {
	let species: NamedAPIResource
	let evolves_to: [ChainLink]
}

// MARK: - View Models types
struct PokemonSummary: Identifiable, Equatable {
	let id: Int
	let name: String
	let artworkURL: URL?
}

struct PokemonDetail: Identifiable, Equatable {
	let id: Int
	let name: String
	let numberText: String
	let artworkURL: URL?
	let types: [String]
	let description: String
	let heightText: String
	let weightText: String
	let stats: [(name: String, value: Int)]
	let abilities: [String]
	let hiddenAbility: String?
	let evolutionChain: [PokemonSummary]
	
	static func == (lhs: PokemonDetail, rhs: PokemonDetail) -> Bool {
		return lhs.id == rhs.id &&
			   lhs.name == rhs.name &&
			   lhs.numberText == rhs.numberText &&
			   lhs.artworkURL == rhs.artworkURL &&
			   lhs.types == rhs.types &&
			   lhs.description == rhs.description &&
			   lhs.heightText == rhs.heightText &&
			   lhs.weightText == rhs.weightText &&
			   lhs.stats.count == rhs.stats.count &&
			   zip(lhs.stats, rhs.stats).allSatisfy { $0.name == $1.name && $0.value == $1.value } &&
			   lhs.abilities == rhs.abilities &&
			   lhs.hiddenAbility == rhs.hiddenAbility &&
			   lhs.evolutionChain == rhs.evolutionChain
	}
}
