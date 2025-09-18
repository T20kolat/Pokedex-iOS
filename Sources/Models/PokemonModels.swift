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

// MARK: - Rarity System
enum PokemonRarity: String, CaseIterable {
	case common = "Common"
	case uncommon = "Uncommon"
	case rare = "Rare"
	case epic = "Epic"
	case legendary = "Legendary"
	case mythical = "Mythical"
	
	var color: String {
		switch self {
		case .common: return "gray"
		case .uncommon: return "green"
		case .rare: return "blue"
		case .epic: return "purple"
		case .legendary: return "orange"
		case .mythical: return "pink"
		}
	}
	
	var glowColor: String {
		switch self {
		case .common: return "gray"
		case .uncommon: return "green"
		case .rare: return "blue"
		case .epic: return "purple"
		case .legendary: return "gold"
		case .mythical: return "rainbow"
		}
	}
	
	static func rarity(for pokemonId: Int) -> PokemonRarity {
		// Legendary Pokémon (Gen 1-9)
		let legendaryIds = [
			144, 145, 146, 150, 151, // Gen 1
			243, 244, 245, 249, 250, 251, // Gen 2
			377, 378, 379, 380, 381, 382, 383, 384, 385, 386, // Gen 3
			480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, // Gen 4
			494, 638, 639, 640, 641, 642, 643, 644, 645, 646, 647, 648, 649, // Gen 5
			716, 717, 718, 719, 720, 721, // Gen 6
			772, 773, 774, 775, 776, 777, 778, 779, 780, 781, 782, 783, 784, 785, 786, 787, 788, 789, 790, 791, 792, 793, 794, 795, 796, 797, 798, 799, 800, 801, 802, // Gen 7
			807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 817, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827, 828, 829, 830, 831, 832, 833, 834, 835, 836, 837, 838, 839, 840, 841, 842, 843, 844, 845, 846, 847, 848, 849, 850, 851, 852, 853, 854, 855, 856, 857, 858, 859, 860, 861, 862, 863, 864, 865, 866, 867, 868, 869, 870, 871, 872, 873, 874, 875, 876, 877, 878, 879, 880, 881, 882, 883, 884, 885, 886, 887, 888, 889, 890, 891, 892, 893, 894, 895, 896, 897, 898, 899, 900, 901, 902, 903, 904, 905, 906, 907, 908, 909, 910, 911, 912, 913, 914, 915, 916, 917, 918, 919, 920, 921, 922, 923, 924, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 947, 948, 949, 950, 951, 952, 953, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964, 965, 966, 967, 968, 969, 970, 971, 972, 973, 974, 975, 976, 977, 978, 979, 980, 981, 982, 983, 984, 985, 986, 987, 988, 989, 990, 991, 992, 993, 994, 995, 996, 997, 998, 999, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008 // Gen 8-9
		]
		
		// Mythical Pokémon (special event Pokémon)
		let mythicalIds = [151, 251, 385, 386, 490, 491, 492, 493, 494, 647, 648, 649, 719, 720, 721, 801, 802, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 817, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827, 828, 829, 830, 831, 832, 833, 834, 835, 836, 837, 838, 839, 840, 841, 842, 843, 844, 845, 846, 847, 848, 849, 850, 851, 852, 853, 854, 855, 856, 857, 858, 859, 860, 861, 862, 863, 864, 865, 866, 867, 868, 869, 870, 871, 872, 873, 874, 875, 876, 877, 878, 879, 880, 881, 882, 883, 884, 885, 886, 887, 888, 889, 890, 891, 892, 893, 894, 895, 896, 897, 898, 899, 900, 901, 902, 903, 904, 905, 906, 907, 908, 909, 910, 911, 912, 913, 914, 915, 916, 917, 918, 919, 920, 921, 922, 923, 924, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 947, 948, 949, 950, 951, 952, 953, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964, 965, 966, 967, 968, 969, 970, 971, 972, 973, 974, 975, 976, 977, 978, 979, 980, 981, 982, 983, 984, 985, 986, 987, 988, 989, 990, 991, 992, 993, 994, 995, 996, 997, 998, 999, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008]
		
		// Epic Pokémon (pseudo-legendaries and special Pokémon)
		let epicIds = [149, 248, 373, 376, 445, 473, 612, 621, 623, 635, 637, 645, 646, 647, 648, 649, 715, 716, 717, 718, 719, 720, 721, 772, 773, 774, 775, 776, 777, 778, 779, 780, 781, 782, 783, 784, 785, 786, 787, 788, 789, 790, 791, 792, 793, 794, 795, 796, 797, 798, 799, 800, 801, 802]
		
		// Rare Pokémon (evolved forms and special Pokémon)
		let rareIds = [3, 6, 9, 12, 15, 18, 20, 22, 24, 26, 28, 31, 34, 36, 38, 40, 42, 45, 47, 49, 51, 53, 55, 57, 59, 62, 65, 68, 71, 73, 76, 78, 80, 82, 85, 87, 89, 91, 94, 95, 97, 99, 101, 103, 105, 106, 107, 108, 110, 112, 113, 115, 117, 119, 121, 122, 123, 124, 125, 126, 127, 128, 130, 131, 132, 134, 135, 136, 137, 139, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151]
		
		if mythicalIds.contains(pokemonId) {
			return .mythical
		} else if legendaryIds.contains(pokemonId) {
			return .legendary
		} else if epicIds.contains(pokemonId) {
			return .epic
		} else if rareIds.contains(pokemonId) {
			return .rare
		} else if pokemonId % 10 == 0 || pokemonId % 15 == 0 {
			return .uncommon
		} else {
			return .common
		}
	}
}

// MARK: - View Models types
struct PokemonSummary: Identifiable, Equatable {
	let id: Int
	let name: String
	let artworkURL: URL?
	
	var rarity: PokemonRarity {
		PokemonRarity.rarity(for: id)
	}
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
