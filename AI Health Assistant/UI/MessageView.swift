import SwiftUI

struct UserMessageView: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Spacer()
            Text(message.content)
                .font(.custom("JosefinSans-VariableFont_wght", size: 16, relativeTo: .body))
                .padding(12)
                .lineSpacing(8)
                .background(Color(red: 218/255, green: 112/255, blue: 214/255))
                .foregroundColor(.white)
                .cornerRadius(18)
                .cornerRadius(4, corners: [.topRight])
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
