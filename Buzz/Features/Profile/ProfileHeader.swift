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
        LinearGradient(
            colors: [profile.accent.opacity(0.35), profile.accent.opacity(0.08), .clear],
            startPoint: .top, endPoint: .bottom
        )
        .frame(height: 140)
    }

    private var nameBlock: some View {
        VStack(spacing: 2) {
            HStack(spacing: BuzzSpacing.xs) {
                Text(profile.displayName)
                    .font(BuzzFont.title)
                    .foregroundStyle(BuzzColor.textPrimary)
                if let p = profile.pronouns {
                    Text("(\(p))")
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textTertiary)
                }
            }
            Text(profile.displayHandle)
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
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
