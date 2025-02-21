//
//  MatchCardView.swift
//  MatchMate
//
//  Created by Mohammed.10824935 on 20/02/25.
//


import SwiftUI
import SDWebImageSwiftUI

struct MatchCardView: View {
    @ObservedObject var user: UserProfile
    var isOffline: Bool // Pass network status
    var onAccept: () -> Void
    var onDecline: () -> Void
    @State private var localImage: UIImage? = nil  //Store loaded image

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.9
            let cardHeight = cardWidth * 1.1

            VStack {
                ZStack(alignment: .bottomLeading) {
                    if isOffline, let localPath = user.localImagePath {
                        //Load Local Image If Available
                        if let image = localImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: cardWidth, height: cardHeight)
                                .cornerRadius(16)
                                .clipped()
                        } else {
                            Color.gray.opacity(0.3) // Placeholder while loading
                                .frame(width: cardWidth, height: cardHeight)
                                .cornerRadius(16)
                                .onAppear {
                                    loadLocalImage(from: localPath)
                                }
                        }
                    } else {
                        // Load Image from Server with SDWebImage (Fast & Cached)
                        WebImage(url: URL(string: user.imageUrl ?? ""))
                            .resizable() //Show activity indicator while loading
                            .aspectRatio(contentMode: .fill)
                            .frame(width: cardWidth, height: cardHeight)
                            .cornerRadius(16)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(user.name ?? "N/A"), \(user.age)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("\(user.city ?? "Unknown"), \(user.country ?? "Unknown")")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                .frame(width: cardWidth, height: cardHeight)

                //Show Status Instead of Buttons
                if let status = user.status, status != "None" {
                    Text(status)
                        .font(.headline)
                        .foregroundColor(status == "Accepted" ? .green : .red)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.3), radius: 5)
                        )
                        .padding(.top, 16)
                } else {
                    HStack(spacing: 40) {
                        Button(action: { onDecline() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                                .frame(width: 60, height: 60)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }

                        Button(action: { onAccept() }) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.pink)
                                .frame(width: 60, height: 60)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: 500)
    }

    //Load Local Image in Background
    private func loadLocalImage(from path: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let image = UIImage(contentsOfFile: path) {
                DispatchQueue.main.async {
                    self.localImage = image
                }
            }
        }
    }
}
