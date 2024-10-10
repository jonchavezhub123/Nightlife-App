//
//  Bar.swift
//  Nightlife
//
//  Created by Jhon Chavez on 10/7/24.
//


import Foundation
import CoreLocation

struct Bar: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let vicinity: String
    let rating: Double
    let userRatingsTotal: Int
    let latitude: Double
    let longitude: Double
    let types: [String]
    let openingHours: [String]
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "place_id"
        case name, vicinity, rating
        case userRatingsTotal = "user_ratings_total"
        case latitude, longitude, types
        case openingHours = "opening_hours"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        vicinity = try container.decode(String.self, forKey: .vicinity)
        rating = try container.decode(Double.self, forKey: .rating)
        userRatingsTotal = try container.decode(Int.self, forKey: .userRatingsTotal)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        types = try container.decode([String].self, forKey: .types)
       // openingHours = try container.decodeIfPresent([String].self, forKey: .openingHours) ?? []
        if let openingHoursContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .openingHours) {
                  openingHours = try openingHoursContainer.decode([String].self, forKey: .openingHours)
              } else {
                  // If opening_hours is directly an array
                  openingHours = try container.decodeIfPresent([String].self, forKey: .openingHours) ?? []
              }
    }
    // This fixes some of the scenarios after midnight not all of them
    /*
    func isOpen(testTime: Date? = nil) -> Bool {
        let currentDay = getCurrentDay()
        print("Current day: \(currentDay)")
        
        print("NAME OF BAR: \(name)")
        
        guard let hoursForToday = openingHours.first(where: { $0.hasPrefix(currentDay) }) else {
            print("No hours found for \(currentDay)")
            return false
        }
        
        print("Hours found for today: \(hoursForToday)")

        let components = hoursForToday.components(separatedBy: ": ")
        guard components.count == 2 else {
            print("Invalid format for hours: \(hoursForToday)")
            return false
        }

        // Normalize the time string
        let normalizedTimeString = components[1]
            .replacingOccurrences(of: "\u{202f}", with: " ")
            .replacingOccurrences(of: "\u{2009}", with: " ")
            .replacingOccurrences(of: "\u{2013}", with: "-")
        
        print("Normalized time string: \(normalizedTimeString)")

        let times = normalizedTimeString.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) }
        print("Split times: \(times)")
        
        guard times.count == 2 else {
            print("Invalid time range: \(normalizedTimeString)")
            return false
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
        
        // Function to determine if a time string includes AM/PM
        func hasAMPM(_ timeString: String) -> Bool {
            return timeString.lowercased().contains("am") || timeString.lowercased().contains("pm")
        }
        
        // Function to append AM/PM if needed
        func appendAMPMIfNeeded(_ timeString: String, referenceTimeString: String) -> String {
            if hasAMPM(timeString) {
                return timeString
            }
            let hour = Int(timeString.components(separatedBy: ":")[0]) ?? 0
            if referenceTimeString.lowercased().contains("pm") && hour < 12 {
                return timeString + " PM"
            }
            return hour < 12 ? timeString + " AM" : timeString + " PM"
        }
        
        let openTimeString = appendAMPMIfNeeded(times[0], referenceTimeString: times[1])
        let closeTimeString = hasAMPM(times[1]) ? times[1] : appendAMPMIfNeeded(times[1], referenceTimeString: times[0])
        
        print("Adjusted open time: \(openTimeString)")
        print("Adjusted close time: \(closeTimeString)")
        
        dateFormatter.dateFormat = "h:mm a"
        
        guard let openTime = dateFormatter.date(from: openTimeString),
              let closeTime = dateFormatter.date(from: closeTimeString) else {
            print("Failed to parse adjusted times: \(openTimeString) or \(closeTimeString)")
            return false
        }
        
        let calendar = Calendar.current
        let now = testTime ?? Date()
        
        func getMinutesSinceMidnight(from date: Date) -> Int {
            let components = calendar.dateComponents([.hour, .minute], from: date)
            return (components.hour ?? 0) * 60 + (components.minute ?? 0)
        }
        
        var currentMinutes = getMinutesSinceMidnight(from: now)
        var openMinutes = getMinutesSinceMidnight(from: openTime)
        var closeMinutes = getMinutesSinceMidnight(from: closeTime)
        
        print("Current time in minutes: \(currentMinutes)")
        print("Open time in minutes: \(openMinutes)")
        print("Close time in minutes: \(closeMinutes)")
        
        // Handle cases where the closing time is after midnight
        if closeMinutes < openMinutes {
            closeMinutes += 24 * 60
            if currentMinutes < openMinutes {
                currentMinutes += 24 * 60
            }
        }
        
        let isOpen = currentMinutes >= openMinutes && currentMinutes < closeMinutes
        print("Is open: \(isOpen)")
        
        return isOpen
    }
    */
    /*
    func isOpen(testTime: Date? = nil) -> Bool {
        let currentDay = getCurrentDay()
        print("Current day: \(currentDay)")
        
        print("NAME OF BAR: \(name)")
        
        guard let hoursForToday = openingHours.first(where: { $0.hasPrefix(currentDay) }) else {
          //  print("No hours found for \(currentDay)")
            return false
        }
        
        print("Hours found for today: \(hoursForToday)")

        let components = hoursForToday.components(separatedBy: ": ")
        guard components.count == 2 else {
            print("Invalid format for hours: \(hoursForToday)")
            return false
        }

        // Normalize the time string
        let normalizedTimeString = components[1]
            .replacingOccurrences(of: "\u{202f}", with: " ")
            .replacingOccurrences(of: "\u{2009}", with: " ")
            .replacingOccurrences(of: "\u{2013}", with: "-")
        
        print("Normalized time string: \(normalizedTimeString)")

        let times = normalizedTimeString.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) }
        print("Split times: \(times)")
        
        guard times.count == 2 else {
            print("Invalid time range: \(normalizedTimeString)")
            return false
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
        
        // Function to determine if a time string includes AM/PM
        func hasAMPM(_ timeString: String) -> Bool {
            return timeString.contains("AM") || timeString.contains("PM")
        }
        
        // Function to append PM if needed
        func appendPMIfNeeded(_ timeString: String, referenceTimeString: String) -> String {
            if hasAMPM(timeString) {
                return timeString
            }
            // If reference time contains PM and is not 12:XX PM, append PM to this time too
            if referenceTimeString.contains("PM") && !referenceTimeString.hasPrefix("12:") {
                return timeString + " PM"
            }
            // If reference time contains AM, we need to check the hours
            if referenceTimeString.contains("AM") {
                let hour = Int(timeString.components(separatedBy: ":")[0]) ?? 0
                // If the hour is less than 12, assume it's AM, otherwise PM
                return hour < 12 ? timeString + " AM" : timeString + " PM"
            }
            // Default to PM if we can't determine
            return timeString + " PM"
        }
        
        let openTimeString = appendPMIfNeeded(times[0], referenceTimeString: times[1])
        let closeTimeString = hasAMPM(times[1]) ? times[1] : times[1] + " PM"
        
        print("Adjusted open time: \(openTimeString)")
        print("Adjusted close time: \(closeTimeString)")
        
        dateFormatter.dateFormat = "h:mm a"
        
        guard let openTime = dateFormatter.date(from: openTimeString),
              let closeTime = dateFormatter.date(from: closeTimeString) else {
            print("Failed to parse adjusted times: \(openTimeString) or \(closeTimeString)")
            return false
        }
        
        let calendar = Calendar.current
        let now = testTime ?? Date()
        
        func getMinutesSinceMidnight(from date: Date) -> Int {
            let components = calendar.dateComponents([.hour, .minute], from: date)
            return (components.hour ?? 0) * 60 + (components.minute ?? 0)
        }
        
        let currentMinutes = getMinutesSinceMidnight(from: now)
        let openMinutes = getMinutesSinceMidnight(from: openTime)
        var closeMinutes = getMinutesSinceMidnight(from: closeTime)
        
        print("Current time in minutes: \(currentMinutes)")
        print("Open time in minutes: \(openMinutes)")
        print("Close time in minutes: \(closeMinutes)")
        
        if closeMinutes < openMinutes {
            closeMinutes += 24 * 60
            print("Adjusted close time in minutes: \(closeMinutes)")
        }
        
        let isOpen = currentMinutes >= openMinutes && currentMinutes <= closeMinutes
        print("Is open: \(isOpen)")
        
        return isOpen
    }
    */
  /*
    // Helper function to get the current day
    private func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: Date())
    }
*/
    // Implement Equatable
    static func == (lhs: Bar, rhs: Bar) -> Bool {
        lhs.id == rhs.id
    }
    
    func isOpen(testTime: Date? = nil) -> Bool {
        let calendar = Calendar.current
        let now = testTime ?? Date()
        
        // Determine if we should use the previous day's hours
        let hour = calendar.component(.hour, from: now)
        let usePreviousDay = hour < 4  // Adjust this threshold as needed
        
        let currentDay = getCurrentDay(for: now, usePreviousDay: usePreviousDay)
        print("Current day: \(currentDay)")
        
        print("NAME OF BAR: \(name)")
        
        guard let hoursForToday = openingHours.first(where: { $0.hasPrefix(currentDay) }) else {
            print("No hours found for \(currentDay)")
            return false
        }
        
        print("Hours found for today: \(hoursForToday)")

        let components = hoursForToday.components(separatedBy: ": ")
        guard components.count == 2 else {
            print("Invalid format for hours: \(hoursForToday)")
            return false
        }

        // Normalize the time string
        let normalizedTimeString = components[1]
            .replacingOccurrences(of: "\u{202f}", with: " ")
            .replacingOccurrences(of: "\u{2009}", with: " ")
            .replacingOccurrences(of: "\u{2013}", with: "-")
        
        print("Normalized time string: \(normalizedTimeString)")

        let times = normalizedTimeString.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) }
        print("Split times: \(times)")
        
        guard times.count == 2 else {
            print("Invalid time range: \(normalizedTimeString)")
            return false
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
        
        // Function to determine if a time string includes AM/PM
        func hasAMPM(_ timeString: String) -> Bool {
            return timeString.lowercased().contains("am") || timeString.lowercased().contains("pm")
        }
        
        // Function to append AM/PM if needed
        func appendAMPMIfNeeded(_ timeString: String, referenceTimeString: String) -> String {
            if hasAMPM(timeString) {
                return timeString
            }
            let hour = Int(timeString.components(separatedBy: ":")[0]) ?? 0
            if referenceTimeString.lowercased().contains("pm") && hour < 12 {
                return timeString + " PM"
            }
            return hour < 12 ? timeString + " AM" : timeString + " PM"
        }
        
        let openTimeString = appendAMPMIfNeeded(times[0], referenceTimeString: times[1])
        let closeTimeString = hasAMPM(times[1]) ? times[1] : appendAMPMIfNeeded(times[1], referenceTimeString: times[0])
        
        print("Adjusted open time: \(openTimeString)")
        print("Adjusted close time: \(closeTimeString)")
        
        dateFormatter.dateFormat = "h:mm a"
        
        guard let openTime = dateFormatter.date(from: openTimeString),
              let closeTime = dateFormatter.date(from: closeTimeString) else {
            print("Failed to parse adjusted times: \(openTimeString) or \(closeTimeString)")
            return false
        }
        
        func getMinutesSinceMidnight(from date: Date) -> Int {
            let components = calendar.dateComponents([.hour, .minute], from: date)
            return (components.hour ?? 0) * 60 + (components.minute ?? 0)
        }
        
        var currentMinutes = getMinutesSinceMidnight(from: now)
        var openMinutes = getMinutesSinceMidnight(from: openTime)
        var closeMinutes = getMinutesSinceMidnight(from: closeTime)
        
        print("Current time in minutes: \(currentMinutes)")
        print("Open time in minutes: \(openMinutes)")
        print("Close time in minutes: \(closeMinutes)")
        
        // Handle cases where the closing time is after midnight
        if closeMinutes < openMinutes {
            closeMinutes += 24 * 60
        }
        
        // If we're using the previous day's hours and it's currently after midnight
        if usePreviousDay && currentMinutes < closeMinutes {
            currentMinutes += 24 * 60
        }
        
        let isOpen = currentMinutes >= openMinutes && currentMinutes < closeMinutes
        print("Is open: \(isOpen)")
        
        return isOpen
    }

    // Helper function to get the current day, with option to get previous day
    private func getCurrentDay(for date: Date, usePreviousDay: Bool) -> String {
        let calendar = Calendar.current
        let dateToUse = usePreviousDay ? calendar.date(byAdding: .day, value: -1, to: date)! : date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: dateToUse)
    }
}
