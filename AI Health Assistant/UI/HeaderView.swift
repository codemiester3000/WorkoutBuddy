import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            Spacer()
            Text("HealthGPT")
                .font(.custom("JosefinSans-VariableFont_wght", size: 16, relativeTo: .body))
                .foregroundColor(.primary.opacity(0.5))
            Spacer()
        }
        .padding()
    }
}
