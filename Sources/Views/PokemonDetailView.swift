import SwiftUI

struct PokemonDetailView: View {
	@StateObject private var vm: PokemonDetailViewModel
	@State private var showHeader = false
	@State private var showContent = false

	init(id: Int) {
		_vm = StateObject(wrappedValue: PokemonDetailViewModel(id: id))
	}

	var body: some View {
		ZStack {
			PlayfulBackground()
				.opacity(0.5)
				.blur(radius: 8)
			ScrollView {
				if let detail = vm.detail {
					VStack(alignment: .leading, spacing: 16) {
						ZStack {
							RoundedRectangle(cornerRadius: 24)
								.fill(LinearGradient(colors: [.yellow.opacity(0.25), .red.opacity(0.2)], startPoint: .top, endPoint: .bottom))
								.frame(height: 240)
								.overlay(
									Circle()
										.fill(Color.white.opacity(0.5))
										.scaleEffect(1.2)
										.blur(radius: 30)
								)
							AsyncImage(url: detail.artworkURL) { phase in
								switch phase {
								case .success(let image):
									image.resizable().scaledToFit()
										.frame(height: 220)
										.shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 6)
										.scaleEffect(showHeader ? 1.0 : 0.9)
										.opacity(showHeader ? 1.0 : 0.0)
										.animation(.spring(response: 0.6, dampingFraction: 0.8), value: showHeader)
								case .failure(_):
									Image(systemName: "questionmark.circle")
										.resizable().scaledToFit().frame(height: 160)
								case .empty:
									ProgressView()
										.frame(height: 160)
								@unknown default:
									EmptyView()
								}
							}
						}

						HStack(alignment: .firstTextBaseline) {
							Text(detail.name)
								.font(.largeTitle.bold())
							Spacer()
							Text(detail.numberText)
								.font(.title3.monospacedDigit())
								.foregroundColor(.secondary)
						}
						.opacity(showContent ? 1 : 0)
						.offset(y: showContent ? 0 : 8)
						.animation(.easeOut(duration: 0.35), value: showContent)

						ScrollView(.horizontal, showsIndicators: false) {
							HStack { ForEach(detail.types, id: \.self) { TypeBadge(type: $0) } }
						}
						.opacity(showContent ? 1 : 0)
						.offset(y: showContent ? 0 : 8)
						.animation(.easeOut(duration: 0.35).delay(0.05), value: showContent)

						Text(detail.description)
							.font(.body)
							.foregroundColor(.secondary)
							.opacity(showContent ? 1 : 0)
							.offset(y: showContent ? 0 : 8)
							.animation(.easeOut(duration: 0.35).delay(0.1), value: showContent)

						HStack(spacing: 24) {
							Label(detail.heightText, systemImage: "ruler")
							Label(detail.weightText, systemImage: "scalemass")
						}
						.font(.subheadline)
						.opacity(showContent ? 1 : 0)
						.offset(y: showContent ? 0 : 8)
						.animation(.easeOut(duration: 0.35).delay(0.15), value: showContent)

						VStack(alignment: .leading, spacing: 8) {
							Text("Base Stats").font(.headline)
							ForEach(detail.stats, id: \.name) { stat in
								StatBar(name: stat.name, value: stat.value, maxValue: 180)
							}
						}
						.opacity(showContent ? 1 : 0)
						.offset(y: showContent ? 0 : 8)
						.animation(.easeOut(duration: 0.35).delay(0.2), value: showContent)

						VStack(alignment: .leading, spacing: 8) {
							Text("Abilities").font(.headline)
							Text(detail.abilities.joined(separator: ", "))
								.font(.subheadline)
							if let hidden = detail.hiddenAbility {
								Text("Hidden: \(hidden)")
									.font(.subheadline)
									.foregroundColor(.secondary)
							}
						}
						.opacity(showContent ? 1 : 0)
						.offset(y: showContent ? 0 : 8)
						.animation(.easeOut(duration: 0.35).delay(0.25), value: showContent)

						VStack(alignment: .leading, spacing: 8) {
							Text("Evolution Chain").font(.headline)
							EvolutionChainView(chain: detail.evolutionChain)
						}
						.opacity(showContent ? 1 : 0)
						.offset(y: showContent ? 0 : 8)
						.animation(.easeOut(duration: 0.35).delay(0.3), value: showContent)
					}
					.padding()
				} else if vm.isLoading {
					ProgressView("Loading...")
						.font(.title3)
						.padding()
				} else if let error = vm.errorMessage {
					VStack(spacing: 12) {
						Text("Error: \(error)")
						Button("Retry") { Task { await vm.load() } }
					}
					.padding()
				}
			}
		}
		.navigationTitle("Details")
		.navigationBarTitleDisplayMode(.inline)
		.task {
			await vm.load()
			withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { showHeader = true }
			withAnimation(.easeOut(duration: 0.5).delay(0.05)) { showContent = true }
		}
	}
}

struct PokemonDetailView_Previews: PreviewProvider {
	static var previews: some View {
		PokemonDetailView(id: 1)
	}
}
