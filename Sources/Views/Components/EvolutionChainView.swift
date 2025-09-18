import SwiftUI

struct EvolutionChainView: View {
	let chain: [PokemonSummary]
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 12) {
				ForEach(Array(chain.enumerated()), id: \.offset) { index, item in
					VStack {
						AsyncImage(url: item.artworkURL) { phase in
							switch phase {
							case .success(let image):
								image.resizable().scaledToFit()
									.frame(width: 72, height: 72)
									.shadow(radius: 3)
							case .failure(_):
								Image(systemName: "questionmark.circle")
									.resizable().scaledToFit()
									.frame(width: 72, height: 72).foregroundColor(.gray)
							case .empty:
								ProgressView().frame(width: 72, height: 72)
							@unknown default:
								EmptyView()
							}
						}
						Text(item.name)
							.font(.caption)
					}
					if index < chain.count - 1 {
						Image(systemName: "chevron.right")
							.font(.headline)
							.foregroundColor(.secondary)
					}
				}
			}
			.padding(.horizontal)
		}
	}
}
