import SwiftUI

struct ProfileAvatar: View {
    let profile: Profile
    var size: CGFloat = 96

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [profile.accent, profile.accent.opacity(0.25), profile.accent],
                        center: .center
                    ),
                    lineWidth: 3
                )
                .frame(width: size + 10, height: size + 10)

            if let url = profile.avatarURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    initials
                }
                .frame(width: size, height: size)
                .clipShape(Circle())
            } else {
                initials
            }
        }
    }

    private var initials: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [profile.accent.opacity(0.9), profile.accent.opacity(0.5)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Text(profile.initials)
                    .font(.system(size: size * 0.36, weight: .heavy, design: .rounded))
                    .foregroundStyle(.black)
            )
    }
}
