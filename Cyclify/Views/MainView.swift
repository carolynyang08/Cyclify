//
//  MainView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/23/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query(filter: #Predicate<UserModel> { user in
        user.isLoggedIn == true
    }) private var users: [UserModel]

    @Environment(\.modelContext) private var modelContext
//    @Query private var users: [UserModel]
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var calibrationModel: CalibrationModel
    
    
    @State private var showingCalibration = false
    @Query private var rides: [Ride]
    @Query var allAlerts: [RideAlert]
    
    
    

    
    let customBlue = Color(red: 8 / 255, green: 196 / 255, blue: 252 / 255)
    let customSky = Color(red: 99 / 255.0, green: 197 / 255.0, blue: 218 / 255.0)
    let customLavender = Color(red: 184 / 255.0, green: 180 / 255.0, blue: 244 / 255.0)

    
    
    
    var currentUser: UserModel? {
        users.first
    }
    
    var todayRide: Ride? {
        let calendar = Calendar.current
        return currentUser?.rides
            .filter { calendar.isDateInToday($0.startTime) }
            .sorted(by: { $0.startTime > $1.startTime })
            .first
    }
    
    var weeklyDuration: TimeInterval {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let thisWeekRides = currentUser?.rides.filter { $0.startTime >= startOfWeek } ?? []
        return thisWeekRides.reduce(0) { $0 + $1.duration }
    }
    

    var body: some View {
        let feedback = personalizedFeedback
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hi, \(currentUser?.firstName ?? "Cyclist")")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Let’s go for a ride.")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 25)
                

        Group {
         if let ride = todayRide {
             NavigationLink(destination: RideDetailView(ride: ride)) {
                 HStack {
                     VStack(alignment: .leading, spacing: 30) {
                         Text("Today’s Ride")
                             .font(.title)
                             .fontWeight(.bold)

                         Text("View Activity")
                             .font(.headline)
                             .padding(8)
                             .background(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
                             .foregroundColor(.white)
                             .cornerRadius(10)
                     }
                     Spacer()
                     Image(systemName: "bicycle")
                         .resizable()
                         .frame(width: 100, height: 75)
                         .foregroundColor(.white)
                 }
                 .padding()
                 .background(customBlue)
                 .cornerRadius(20)
                 .padding(.horizontal)
             }
         } else {
             HStack {
                 VStack(alignment: .leading, spacing: 30) {
                     Text("Today’s Ride")
                         .font(.title)
                         .fontWeight(.bold)

                     Text("Your workout log is empty today.")
                         .font(.headline)
                         .foregroundColor(.white)
                 }
                 Spacer()
                 Image(systemName: "bicycle")
                     .resizable()
                     .frame(width: 100, height: 75)
                     .foregroundColor(.white)
             }
             .padding()
             .background(customBlue)
             .cornerRadius(20)
             .padding(.horizontal)
         }
     }
        
                Text("This Week")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 16) {
                if let user = currentUser {
                    let delta = rideScoreImprovement(for: user) ?? 0
                    VStack {
                        Text("Form Improvement")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text(delta >= 0 ? "+\(delta)" : "\(delta)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(customSky)
                    .cornerRadius(10)
                }


                VStack {
                    Text("Duration")
                        .font(.caption)
                        .fontWeight(.bold)
                    Text(formattedDuration(from: weeklyDuration))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(customSky)
                .cornerRadius(10)
            }
            .padding(.horizontal)
                
                Text("Personalized Ride Tips")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("• \(feedback.form)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("• \(feedback.heartRate)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
//                .padding()
//                .background(customLavender)
//                .cornerRadius(10)
//                .padding(.horizontal)



                .padding()
                .background(customLavender)
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    showingCalibration = true
                }) {
                    Text("Calibrate")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(customBlue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                
            }
            .padding(.top)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .foregroundColor(.white)
            .preferredColorScheme(.dark)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Menu {
                    Button("Logout", role: .destructive) {
                        logout()
                    }
                   } label: {
                       Image(systemName: "line.horizontal.3")
                           .resizable()
                           .frame(width: 24, height: 18)
                           .foregroundColor(.white)
                           .padding(.leading)
                   }
               )
            .fullScreenCover(isPresented: $showingCalibration) {
                           NavigationStack {
                               if let user = currentUser {
                                   CalibrationIntroView(
                                       userModel: user,
                                       bluetoothManager: bluetoothManager,
                                       calibrationModel: calibrationModel
                                   )
                               }
                }
            }
        }
    }
    private func rideScoreImprovement(for user: UserModel) -> Int? {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfThisWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let startOfLastWeek = calendar.date(byAdding: .day, value: -7, to: startOfThisWeek) else {
            return nil
        }

        let thisWeekScores = user.rides
            .filter { $0.startTime >= startOfThisWeek && ($0.rideScore ?? -1) >= 0 }
            .map { $0.rideScore ?? 0 }

        let lastWeekScores = user.rides
            .filter { $0.startTime >= startOfLastWeek && $0.startTime < startOfThisWeek && ($0.rideScore ?? -1) >= 0 }
            .map { $0.rideScore ?? 0 }

        guard !thisWeekScores.isEmpty, !lastWeekScores.isEmpty else { return nil }

        let avgThis = Double(thisWeekScores.reduce(0, +)) / Double(thisWeekScores.count)
        let avgLast = Double(lastWeekScores.reduce(0, +)) / Double(lastWeekScores.count)
        
        return Int((avgThis - avgLast).rounded())
    }
    
    private func formTip(for type: Int?) -> String {
        switch type {
        case 1:
            return "You're putting more effort on the left side of your body. Try to rebalance your weight to stay smooth and efficient."
        case 2:
            return "You're putting more effort on the right side of your body. Aim for better symmetry to avoid muscle imbalances."
        case 3:
            return "You're leaning forward too much. Engage your core and try to keep a stable posture."
        case 4:
            return "You're leaning back frequently. Maintain an active forward position to keep power transfer efficient."
        default:
            return "Watch your posture. Consistent form breakdowns affect ride efficiency."
        }
    }

    private var personalizedFeedback: (form: String, heartRate: String) {
        guard let user = currentUser else {
            return ("We couldn't analyze your form yet.", "No heart rate data available.")
        }

        let alertType = mostCommonAlertThisWeek(for: user)
        let avgHR = averageHeartRateThisWeek(for: user)

        return (formTip(for: alertType), heartRateTip(for: avgHR))
    }

    private func heartRateTip(for avgHR: Double?) -> String {
        guard let hr = avgHR else {
            return "We couldn't calculate your heart rate trend. Try completing a full ride with Watch paired."
        }
        switch hr {
        case ..<110:
            return "You've been riding mostly in Zone 1 (Recovery). Consider adding higher intensity intervals to challenge your fitness."
        case 110..<130:
            return "You've been riding in Zone 2 (Endurance). Great for base-building. Mix in some tempo work too!"
        case 130..<150:
            return "You're spending time in Zone 3 (Tempo). Nice work! consider some sprints or VO₂ intervals."
        default:
            return "You're hitting high intensity zones consistently. Make sure you're recovering adequately between rides."
        }
    }


    private func mostCommonAlertThisWeek(for user: UserModel) -> Int? {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()

        let rideIds = user.rides
            .filter { $0.startTime >= startOfWeek }
            .map(\.id)

        let thisWeeksAlerts = allAlerts
            .filter { alert in alert.ride != nil && rideIds.contains(alert.ride!.id) }

        let alertCounts = Dictionary(grouping: thisWeeksAlerts, by: \.type)
            .mapValues { $0.count }

        return alertCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private func averageHeartRateThisWeek(for user: UserModel) -> Double? {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()

        let weeklyHRs = user.rides
            .filter { $0.startTime >= startOfWeek }
            .compactMap { $0.averageHeartRate }
            .filter { $0 > 0 }

        guard !weeklyHRs.isEmpty else { return nil }

        let total = weeklyHRs.reduce(0, +)
        return Double(total) / Double(weeklyHRs.count)
    }


    @ViewBuilder
    private func personalizedTipsSection(for user: UserModel) -> some View {
        let alertType = mostCommonAlertThisWeek(for: user)
        let avgHR = averageHeartRateThisWeek(for: user)
        let formFeedback = formTip(for: alertType)
        let hrFeedback = heartRateTip(for: avgHR)

        VStack(alignment: .leading, spacing: 10) {
            Text("• \(formFeedback)")
                .font(.subheadline)
                .fontWeight(.bold)

            Text("• \(hrFeedback)")
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding()
        .background(customLavender)
        .cornerRadius(10)
        .padding(.horizontal)
    }


    
    private func formattedDuration(from seconds: TimeInterval) -> String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .abbreviated
            return formatter.string(from: seconds) ?? "0m"
        }
    
    private func logout() {
        if let user = users.first(where: { $0.isLoggedIn }) {
            user.isLoggedIn = false
            do {
                try modelContext.save()
                print("User logged out")
            } catch {
                print("Failed to save logout: \(error)")
            }
        }
    }

}





struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(for: UserModel.self, Ride.self, SensorReading.self)
        let context = container.mainContext

        // Optional: insert a test user
        let mockUser = UserModel(
            email: "preview@example.com",
            firstName: "Preview",
            lastName: "User",
            weight: 150,
            weightUnit: "LB",
            heightFeet: 5,
            heightInches: 10
        )
        context.insert(mockUser)

        return MainView(
            bluetoothManager: BluetoothManager(),
            calibrationModel: CalibrationModel()
        )
        .modelContainer(container)
    }
}
