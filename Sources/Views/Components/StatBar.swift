import SwiftUI

struct StatBar: View {
	let name: String
	let value: Int
	let maxValue: Double
	@State private var animatedWidth: CGFloat = 0

	var body: some View {
		HStack {
			Text(name)
				.font(.caption)
				.frame(width: 90, alignment: .leading)
			GeometryReader { geo in
				ZStack(alignment: .leading) {
					RoundedRectangle(cornerRadius: 6)
						.fill(Color.gray.opacity(0.15))
						.frame(height: 10)
					RoundedRectangle(cornerRadius: 6)
						.fill(gradient)
						.frame(width: animatedWidth, height: 10)
				}
				.onAppear {
					let target = min(CGFloat(value) / max(CGFloat(maxValue), 1) * geo.size.width, geo.size.width)
					withAnimation(.easeOut(duration: 0.8)) { animatedWidth = target }
				}
			}
			.frame(height: 10)
			Text("\(value)")
				.font(.caption.monospacedDigit())
		}
	}

	private var gradient: LinearGradient {
		LinearGradient(colors: [.red, .orange, .yellow, .green], startPoint: .leading, endPoint: .trailing)
	}
}

struct StatBar_Previews: PreviewProvider {
	static var previews: some View {
		StatBar(name: "HP", value: 78, maxValue: 180)
			.padding()
	}
}
