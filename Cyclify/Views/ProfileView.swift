//
//  ProfileView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/29/25.
//

import SwiftUI
import SwiftData
import Charts


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        (a, r, g, b) = (255, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct RideScoreTrendChart: View {
    let rides: [Ride]
    
    var body: some View {
        let scoredRides = rides
            .filter { $0.rideScore != nil }
            .sorted(by: { $0.startTime < $1.startTime })
        
        if scoredRides.isEmpty {
            Text("No ride scores available.")
                .foregroundColor(.gray)
                .frame(height: 150)
        } else {
            Chart {
                ForEach(scoredRides, id: \.id) { ride in
                    LineMark(
                        x: .value("Date", ride.startTime),
                        y: .value("Score", ride.rideScore ?? 0)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.cyan)
                    .symbol(Circle())
                }
            }
            .frame(height: 200)
            .chartYAxisLabel("Ride Score")
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
        }
    }
}

struct ProfileView: View {
    @Query private var users: [UserModel]
    @Query private var allRides: [Ride]
    @Environment(\.modelContext) private var modelContext

    var currentUser: UserModel? {
        users.first(where: { $0.isLoggedIn })
    }
    

    var body: some View {
        NavigationView {
            ScrollView {
                Text("Activities")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                VStack(spacing: 16) {
                    if let user = currentUser {
                        let userRides = allRides.filter { $0.user?.id == user.id }
                        
                        VStack(alignment: .leading) {
                            Text("Your Ride Score Trend")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)

                            RideScoreTrendChart(rides: userRides)
                                .padding(.horizontal, 10)
                        }
                        
                        ForEach(user.rides.sorted(by: { $0.startTime > $1.startTime })) { ride in

                            RideCardView(ride: ride).swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteRide(ride)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }

                }
                Button("Delete All Rides", role: .destructive) {
                           deleteAllRides()
                       }
                .padding()
            }
            .navigationBarTitleDisplayMode(.large)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }

    private func deleteAllRides() {
        if let user = currentUser {
            for ride in user.rides {
                modelContext.delete(ride)
            }
            do {
                try modelContext.save()
                print("All rides deleted")
            } catch {
                print("Failed to delete rides: \(error)")
            }
        }
    }
        
    private func deleteRide(_ ride: Ride) {
            modelContext.delete(ride)
            do {
                try modelContext.save()
                print("Ride deleted")
            } catch {
                print("Failed to delete ride: \(error)")
            }
    }
}


#Preview {
    let container = try! ModelContainer(
        for: UserModel.self, Ride.self, SensorReading.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext

    let user = UserModel(
        email: "test@example.com",
        firstName: "Test",
        lastName: "User",
        weight: 150,
        weightUnit: "LB",
        heightFeet: 5,
        heightInches: 10
    )
    context.insert(user)

    let ride = Ride(
        startTime: Date().addingTimeInterval(-3600),
        endTime: Date(),
        averageHeartRate: 144,
        caloriesBurned: 782
    )
    ride.user = user
    context.insert(ride)

    return ProfileView()
        .modelContainer(container)
}

