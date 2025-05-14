# Cyclify

Welcome to **Cyclify**, a posture-tracking app designed for cyclists. Built as part of the ECE Capstone at Carnegie Mellon University, Cyclify helps users improve riding form using pressure sensors, real-time alerts, and detailed post-ride analytics.

**Capstone Project Page:**  
https://course.ece.cmu.edu/~ece500/projects/s25-teamc4/

## App Overview

Cyclify connects to an ESP32 device embedded with pressure sensors via Bluetooth. It collects data during a ride, alerts users to poor posture using voice feedback, and visualizes their form performance after each ride. The app is iOS-native and uses SwiftUI, CoreBluetooth, SwiftData, and Swift Charts.

## 🔧 Features

- ✅ **Bluetooth Device Pairing** with ESP32
- 🧘 **Posture Calibration** 
- 📊 **Real-Time Sensor Data Collection**
- 🗣️ **Speech Alerts** for posture correction
- 📈 **Swift Charts for Ride Insights**
- 📦 **Persistent Storage with SwiftData**
- ⌚ **Apple Watch Integration** for heart rate and calories

## Screenshots & Demo

### Pairing Screen
<h3>Pairing Screen</h3>
<img src="https://github.com/user-attachments/assets/0b534d38-3792-431b-a373-3bdc4f62470a" alt="Pairing Screen" width="400"/>


### Ride Recording
![Ride View](images/ride.png)

### Ride Summary
![Summary View](images/summary.png)

### Video Demo  
[![Watch on YouTube](images/video-thumbnail.png)]([https://www.youtube.com/watch?v=c8LMHRgGiyw])

> More media available on our [project site](https://course.ece.cmu.edu/~ece500/projects/s25-teamc4/)

---

## Tech Stack

- `SwiftUI` for UI
- `CoreBluetooth` for BLE sensor connection
- `SwiftData` for persistent storage
- `Swift Charts` for ride analytics
- `AVFoundation` for speech feedback
- `WatchConnectivity` for Apple Watch integration


