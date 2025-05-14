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

<h3>Device Pairing</h3>
<img src="https://github.com/user-attachments/assets/0b534d38-3792-431b-a373-3bdc4f62470a" alt="Pairing Screen" width="200"/>

<h3>Landing Page</h3>
<img src="https://github.com/user-attachments/assets/04e2654c-7c05-4765-8747-fb93d2df1d45" alt="Landing Page" width="200"/>

<h3>Ride View</h3>
<img src="https://github.com/user-attachments/assets/87a98c55-d5ff-43cc-aa0d-1f491f31cffe" alt="Ride View" width="200"/>

<h3>Ride Analytics</h3>
<img src="https://github.com/user-attachments/assets/293df885-d3bd-4ee3-b1c5-1eac2a2dfa08" alt="Ride View" width="200"/>

<h3>Apple Watch Integration View</h3>
https://github.com/user-attachments/assets/ca94a045-1795-4ba3-8903-ffa1497e319a

<h3>Calibration Flow</h3>
https://github.com/user-attachments/assets/9b9b12aa-7826-4065-a9a3-ed961ba7f00d

<h3>Pressure Distribution Analytics</h3>
https://github.com/user-attachments/assets/792a2baf-45d3-4178-b7ae-229016b0864a


### Video Demo  
[![Watch the demo](https://img.youtube.com/vi/c8LMHRgGiyw/0.jpg)](https://www.youtube.com/watch?v=c8LMHRgGiyw)


> More media available on our [project site](https://course.ece.cmu.edu/~ece500/projects/s25-teamc4/)

---

## Tech Stack

- `SwiftUI` for UI
- `CoreBluetooth` for BLE sensor connection
- `SwiftData` for persistent storage
- `Swift Charts` for ride analytics
- `AVFoundation` for speech feedback
- `WatchConnectivity` for Apple Watch integration


