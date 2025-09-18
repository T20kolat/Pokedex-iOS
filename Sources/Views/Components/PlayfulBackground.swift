import SwiftUI

struct PlayfulBackground: View {
	@State private var animate = false
	let colors: [Color] = [.red.opacity(0.2), .yellow.opacity(0.2), .blue.opacity(0.2)]

	var body: some View {
		GeometryReader { geo in
			ZStack {
				ForEach(0..<12, id: \.self) { i in
					let size = CGFloat(Int.random(in: 40...120))
					Circle()
						.fill(colors[i % colors.count])
						.frame(width: size, height: size)
						.position(x: CGFloat.random(in: 0...geo.size.width), y: animate ? -40 : geo.size.height + 40)
						.animation(.linear(duration: Double.random(in: 8...16)).repeatForever(autoreverses: false).delay(Double(i) * 0.2), value: animate)
				}
			}
			.onAppear { animate = true }
		}
		.ignoresSafeArea()
	}
}

struct PlayfulBackground_Previews: PreviewProvider {
	static var previews: some View {
		PlayfulBackground()
	}
}
