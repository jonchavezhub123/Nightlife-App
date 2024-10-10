//
//  BarDetailPopup.swift
//  Nightlife
//
//  Created by Jhon Chavez on 10/7/24.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct BarDetailPopup: View {
    let bar: Bar
    let onClose: () -> Void
    @State private var placeDetails: PlaceDetails?
    @State private var isLoading = true
    @State private var error: Error?
    
    // Environment values for dynamic type and color scheme
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            
            if isLoading {
                loadingView
            } else if let error = error {
                errorView(error)
            } else if let details = placeDetails {
                detailsView(details)
            }
            
            actionButtons
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                .shadow(radius: 10)
        )
        .padding()
        .onAppear(perform: fetchDetails)
    }
    
    private var headerView: some View {
        HStack {
            Text(bar.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
            
            Spacer()
            
            Button(action: {
                print("BarDetailPopup: Close button tapped for \(bar.name)")
                onClose()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                    .font(.title2)
            }
            .accessibilityLabel("Close")
        }
    }
    
    private var loadingView: some View {
        HStack {
            ProgressView()
            Text("Loading details...")
                .foregroundColor(.secondary)
        }
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Error loading details", systemImage: "exclamationmark.triangle")
                .foregroundColor(.red)
            Text(error.localizedDescription)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    private func detailsView(_ details: PlaceDetails) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let rating = details.rating {
                ratingView(rating: rating, totalReviews: details.userRatingsTotal ?? 0)
            }
            
            if let address = details.formattedAddress {
                addressView(address)
            }
            
            if let openingHours = details.openingHours {
                openingHoursView(openingHours)
            }
            
            if let review = details.firstReview {
                reviewView(review)
            }
            }
    }
    
    private func openingHoursView(_ openingHours: OpeningHours) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    Text(openingHours.openNow ? "Open" : "Closed")
                        .font(.subheadline)
                        .foregroundColor(openingHours.openNow ? .green : .red)
                        .fontWeight(.semibold)
                }
                
                if let currentPeriod = openingHours.currentPeriod {
                    Text(currentPeriod)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    
    private func addressView(_ address: String) -> some View {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text(address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .padding(.vertical, 4)
        }
    
    // Haven't fixed the last star
    
    private func ratingView(rating: Double, totalReviews: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<5) { index in
                ZStack {
                    // Empty star (background)
                    Image(systemName: "star")
                        .foregroundColor(.yellow.opacity(0.3))
                    
                    // Filled star (foreground)
                    if rating >= Double(index) + 1 {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    } else if rating > Double(index) {
                        GeometryReader { geometry in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .mask(
                                    Rectangle()
                                        .size(width: geometry.size.width * CGFloat(rating - Double(index)), height: geometry.size.height)
                                )
                        }
                    }
                }
                .frame(width: 20, height: 20) // Set fixed frame for each star
            }

            // Rating number and review count
            Text(String(format: "%.1f", rating))
                .fontWeight(.semibold)
            Text("(\(formatReviews(totalReviews)))")
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .frame(height: 20) // Set a fixed height for the overall rating view
    }

       private func starFillAmount(for index: Int, rating: Double) -> Double {
           let fillAmount = rating - Double(index)
           return min(max(fillAmount, 0), 1)
       }
    
    // Helper function to format reviews as before
    private func formatReviews(_ totalReviews: Int) -> String {
        if totalReviews >= 1000 {
            let formattedReviews = Double(totalReviews) / 1000.0
            return String(format: "%.1fK", formattedReviews)
        } else {
            return String(totalReviews)
        }
    }
    
    private func reviewView(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Review")
                .font(.headline)
            Text(review.text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
    }
    
    private func onDirectionsTapped() {
          if let address = placeDetails?.formattedAddress,
             let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
             let url = URL(string: "maps://?q=\(encodedAddress)") {
              UIApplication.shared.open(url)
          }
      }
    
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
                 Button(action: onDirectionsTapped) {
                     Label("Directions", systemImage: "location.fill")
                         .frame(maxWidth: .infinity)
                 }
                 .buttonStyle(.bordered)
                 .disabled(placeDetails?.formattedAddress == nil)
                 
                 Button(action: { /* Implement booking/check-in action */ }) {
                     Label("Check In", systemImage: "checkmark.circle.fill")
                         .frame(maxWidth: .infinity)
                 }
                 .buttonStyle(.borderedProminent)
             }
    }
    
    private func fetchDetails() {
        isLoading = true
        error = nil
        
        fetchPlaceDetails(placeID: bar.id) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let details):
                    self.placeDetails = details
                case .failure(let fetchError):
                    self.error = fetchError
                }
            }
        }
    }
}

// Models
struct PlaceDetails: Codable {
    let name: String
    let formattedAddress: String?
    let rating: Double?
    let userRatingsTotal: Int?
    let website: String?
    let reviews: [Review]?
    let openingHours: OpeningHours?
    
    var firstReview: Review? {
        reviews?.first
    }
}

struct OpeningHours: Codable {
    let openNow: Bool
    let periods: [Period]?
    let weekdayText: [String]?
    
    var currentPeriod: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let currentDay = dateFormatter.string(from: Date())
        
        return weekdayText?.first { $0.starts(with: currentDay) }
    }
}

struct Period: Codable {
    let open: TimeInfo
    let close: TimeInfo?
}

struct TimeInfo: Codable {
    let day: Int
    let time: String
}

struct Review: Codable {
    let authorName: String
    let rating: Int
    let text: String
    let time: Int
}

// API Client
class PlacesAPIClient {
    static let shared = PlacesAPIClient()
    private let apiKey = "API_KEY"
    
    func fetchPlaceDetails(placeID: String) async throws -> PlaceDetails {
        let fields = "name,formatted_address,rating,user_ratings_total,reviews,website,opening_hours"
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=\(fields)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        struct Response: Codable {
            let result: PlaceDetails
        }
        
        let response = try decoder.decode(Response.self, from: data)
        return response.result
    }
}

func fetchPlaceDetails(placeID: String, completion: @escaping (Result<PlaceDetails, Error>) -> Void) {
    Task {
        do {
            let details = try await PlacesAPIClient.shared.fetchPlaceDetails(placeID: placeID)
            completion(.success(details))
        } catch {
            completion(.failure(error))
        }
    }
}
