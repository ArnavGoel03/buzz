import SwiftUI

struct ProfileHeader: View {
    let profile: Profile

    var body: some View {
        VStack(spacing: BuzzSpacing.md) {
            backdrop
                .overlay(alignment: .bottom) {
                    ProfileAvatar(profile: profile)
                        .offset(y: 54)
                }
            Spacer().frame(height: 54)
            nameBlock
            affiliations
            if let bio = profile.bio, !bio.isEmpty {
                Text(bio)
                    .font(BuzzFont.body)
                    .foregroundStyle(BuzzColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BuzzSpacing.xl)
                    .padding(.top, BuzzSpacing.xs)
            }
        }
    }

    private var backdrop: some View {
        ZStack {
            // Giant serif initial parallax in the background — matches web ProfileHero
            Text(profile.displayName.prefix(1).uppercased())
                .font(.system(size: 260, weight: .medium, design: .serif))
                .kerning(-12)
                .foregroundStyle(profile.accent.opacity(0.28))
                .offset(x: 90, y: -24)
                .clipped()

            LinearGradient(
                colors: [profile.accent.opacity(0.35), profile.accent.opacity(0.08), .clear],
                startPoint: .top, endPoint: .bottom
            )
        }
        .frame(height: 160)
        .clipped()
    }

    private var nameBlock: some View {
        VStack(spacing: BuzzSpacing.xs) {
            HStack(spacing: BuzzSpacing.xs) {
                Text(profile.displayName)
                    .font(BuzzFont.display)
                    .kerning(-0.4)
                    .foregroundStyle(BuzzColor.textPrimary)
                if let p = profile.pronouns {
                    Text("(\(p))")
                        .font(BuzzFont.monoSmall)
                        .foregroundStyle(BuzzColor.textTertiary)
                }
            }
            Text(profile.displayHandle.uppercased())
                .font(BuzzFont.monoSmall)
                .tracking(1.4)
                .foregroundStyle(BuzzColor.textTertiary)
        }
    }

    private var affiliations: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BuzzSpacing.sm) {
                ForEach(profile.affiliations) { aff in
                    AffiliationPill(affiliation: aff, isPrimary: aff.id == profile.primaryAffiliationID)
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
        }
    }
}
