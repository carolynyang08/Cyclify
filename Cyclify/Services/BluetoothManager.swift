//
//  BluetoothManager.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/15/25.
//  Responsible for managing BLE connections

import Foundation
import CoreBluetooth
import SwiftData
import SwiftUI
import AVFoundation


enum ConnectionStatus: String{
    case connected
    case disconnected
    case scanning
    case connecting
    case error
    
}

//IDS & CHARACTERISTICS
let SERVICE_UUID: CBUUID = CBUUID(string: "20252025-0000-4000-8000-202520252025")
let UUID_WEIGHT: CBUUID = CBUUID(string: "20252025-0001-4000-8000-202520252025")
let UUID_LEVEL: CBUUID = CBUUID(string: "20252025-0002-4000-8000-202520252025")
let UUID_CALIBRATE_CMD: CBUUID = CBUUID(string: "20252025-0003-4000-8000-202520252025")
let UUID_RIDE_CONTROL: CBUUID = CBUUID(string: "20252025-0004-4000-8000-202520252025")
let UUID_SENSOR_DATA: CBUUID = CBUUID(string: "20252025-1001-4000-8000-202520252025")
let UUID_SENSOR_ALERT: CBUUID = CBUUID(string: "20252025-1002-4000-8000-202520252025")

let UUID_KNEE_ALERT: CBUUID = CBUUID(string: "20252025-1003-4000-8000-202520252025")


class BluetoothManager: NSObject, ObservableObject {
    var modelContext: ModelContext?
    private var centralManager: CBCentralManager! 
    var espPeripheral: CBPeripheral?
    @Published var bufferedReadings: [SensorReading] = []
    @Published var bufferedAlerts: [RideAlert] = []

    private var weightCharacteristic: CBCharacteristic?
    private var levelCharacteristic: CBCharacteristic?
    private var calibrateCharacteristic: CBCharacteristic?
    private var rideControlCharacteristic: CBCharacteristic?
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var speechTimer: Timer?
    private var isRideActive: Bool = false
    
    //Buffer to track incoming alerts in real time
    private var alertHistory: [(timestamp: TimeInterval, alert: RideAlert)] = []
    private var lastSpokenType: Int? = nil
    private var lastSpokenTime: Date? = nil


    
    @Published var peripheralStatus: ConnectionStatus = .disconnected
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var sensorData: String = "Waiting for sensor data"
    @Published var alertMessage: String = ""
    
    
    private var pendingWeight: Int?
    private var pendingLevel: Int?
    private var pendingCalibrationCommand: String?
    private var pendingRideControl: String?
    
    var currentRide: Ride?
   
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startRide() {
        isRideActive = true
        startSpeechTimer()
    }
    
    func stopRide() {
        isRideActive = false
        speechTimer?.invalidate()
        speechTimer = nil
        speechSynthesizer.stopSpeaking(at: .immediate)
        alertHistory.removeAll()
    }

    private func startSpeechTimer() {
        speechTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.evaluateRecentAlerts()
        }
    }

    private func evaluateRecentAlerts() {
        guard isRideActive else { return }
        let now = Date()

        if let lastTime = lastSpokenTime, now.timeIntervalSince(lastTime) < 6 {
            return
        }

        let windowStart = now.timeIntervalSince1970 - 6.5
        let recentAlerts = alertHistory.filter { $0.timestamp >= windowStart }

        let frequencyMap = Dictionary(grouping: recentAlerts, by: { $0.alert.type })
            .mapValues { $0.count }

        guard let (mostFrequentType, _) = frequencyMap.max(by: { $0.value < $1.value }) else { return }

        if mostFrequentType > 0 && mostFrequentType <= AlertType.allCases.count {
            let alertType = AlertType.allCases[mostFrequentType - 1]

            if let intensity = recentAlerts.first(where: { $0.alert.type == mostFrequentType })?.alert.intensity {
                let message = alertType.message(forIntensity: intensity)
                speak(message: message, intensity: intensity)
                lastSpokenType = mostFrequentType
                lastSpokenTime = now
            }
        }
    }

    
    func speak(message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_en-US_compact") // "Shelley"
        utterance.rate = 0.8
        speechSynthesizer.speak(utterance)
    }
    
    //search for bluetooth devices (User presses "Scan for Devices")
    func scanForPeripherals() {
        if centralManager.state == .poweredOn {
            if peripheralStatus != .scanning {
                peripheralStatus = .scanning
                discoveredPeripherals.removeAll()
                centralManager.scanForPeripherals(withServices: [SERVICE_UUID])
                print("Started scanning for peripherals")
        
            }else {
                print("Already scanning for peripherals")
            }
        } else {
            peripheralStatus = .error
            print("Cannot scan: Bluetooth is not powered on.")
        }
    }
    
    func stopScanning() {
        if peripheralStatus == .scanning {
            centralManager.stopScan()
            peripheralStatus = .disconnected
            print("Stopping scanning for peripherals")
        }
    }
    
    func connect(to peripheral: CBPeripheral){
        if peripheralStatus != .connected && peripheralStatus != .connecting {
            espPeripheral = peripheral
            centralManager.connect(peripheral)
            peripheralStatus = .connecting
            stopScanning()
            print("Attempting to connect to \(peripheral.name ?? "Unknown Device")")
        } else {
            print("Cannot connect: Already connected or connecting.")
        }
    }
    
    func disconnect() {
        if let peripheral = espPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            peripheralStatus = .disconnected
            espPeripheral = nil
            weightCharacteristic = nil
            levelCharacteristic = nil
            calibrateCharacteristic = nil
            rideControlCharacteristic = nil
            pendingWeight = nil
            pendingLevel = nil
            pendingCalibrationCommand = nil
            pendingRideControl = nil
            print("Disconnected from \(peripheral.name ?? "Unknown Device")")
        }
    }
    
    func sendWeight(_ weight: Int){
        guard let peripheral = espPeripheral, let characteristic = weightCharacteristic else {
            print("Cannot send weight: No connected peripheral or weight characteristic.")
            pendingWeight = weight
            return
        }
        
        let weightString = String(weight)
        if let data = weightString.data(using: .utf8) {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            print("Sent weight: \(weightString)")
        }
    }
    
    func sendLevel(_ level: Int) {
        guard let peripheral = espPeripheral, let characteristic = levelCharacteristic else {
            print("Cannot send level: No connected peripheral or level characteristic.")
            pendingLevel = level
            return
        }
        let levelString = String(level)
        if let data = levelString.data(using: .utf8) {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            print("Sent level: \(levelString)")
        }
    }
    
    func sendCalibrationCommand(_ command: String){
        guard let peripheral = espPeripheral, let characteristic = calibrateCharacteristic else {
            print("Cannot send calibration command: No connected peripheral or calibration characteristic")
            pendingCalibrationCommand = command
            return
        }
        
        if let data = command.data(using: .utf8){
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            print("Sent calibration command: \(command)")
        }
    }
    
    func sendRideControl(_ command: String){
        guard let peripheral = espPeripheral, let characteristic = rideControlCharacteristic else {
            print("Cannot send rideControl command: No connected peripheral or rideControl characteristic")
            pendingRideControl = command
            return
        }
        
        if let data = command.data(using: .utf8){
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            print("Sent ride control command: \(command)")
        }
    }
    
    func speak(message: String, intensity: Int) {
        let utterance = AVSpeechUtterance(string: message)
        if let shelleyVoice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name == "Shelley" && $0.language == "en-US" }) {
            utterance.voice = shelleyVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // fallback
        }

        
        switch intensity {
            case 1: utterance.rate = 0.3
            case 2: utterance.rate = 0.4
            case 3: utterance.rate = 0.5
            case 4: utterance.rate = 0.6
            case 5: utterance.rate = 0.7
            default: utterance.rate = 0.45
            }

        speechSynthesizer.speak(utterance)
    }

}



extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on.")
            peripheralStatus = .disconnected
        case .poweredOff:
            print("Bluetooth is powered off.")
            peripheralStatus = .error
        case .unauthorized:
            print("Bluetooth access is not authorized.")
            peripheralStatus = .error
        default:
            print("Bluetooth state unknown: \(central.state)")
            peripheralStatus = .error
        
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
            print("Discovered \(peripheral.name ?? "Unknown Device")")
            self.objectWillChange.send()
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralStatus = .connected
        peripheral.delegate = self
        peripheral.discoverServices([SERVICE_UUID])
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        centralManager.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        peripheralStatus = .disconnected
        espPeripheral = nil
        weightCharacteristic = nil
        levelCharacteristic = nil
        rideControlCharacteristic = nil
        calibrateCharacteristic = nil
        pendingWeight = nil
        pendingLevel = nil
        pendingRideControl = nil
        pendingCalibrationCommand = nil
        print("Disconnected from \(peripheral.name ?? "Unknown Device")")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        peripheralStatus = .error
        print("Failed to connect: \(error?.localizedDescription ?? "No description")")
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            peripheralStatus = .error
            return
        }
        
        for service in peripheral.services ?? [] {
            if service.uuid == SERVICE_UUID {
                print("Found service for \(SERVICE_UUID)")
                peripheral.discoverCharacteristics([UUID_WEIGHT, UUID_LEVEL, UUID_CALIBRATE_CMD, UUID_SENSOR_ALERT, UUID_RIDE_CONTROL, UUID_SENSOR_DATA], for: service)
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            peripheralStatus = .error
            return
        }
        
        for characteristic in service.characteristics ?? [] {
            print("Found characteristic: \(characteristic.uuid), waiting on values.")
            if characteristic.uuid == UUID_WEIGHT {
                weightCharacteristic = characteristic
                if let weight = pendingWeight {
                    sendWeight(weight)
                    pendingWeight = nil
                }
            }else if characteristic.uuid == UUID_LEVEL {
                levelCharacteristic = characteristic
                if let level = pendingLevel {
                    sendLevel(level)
                    pendingLevel = nil
                }
            } else if characteristic.uuid == UUID_CALIBRATE_CMD{
                calibrateCharacteristic = characteristic
                if let command = pendingCalibrationCommand {
                    sendCalibrationCommand(command)
                    pendingCalibrationCommand = nil
                }
            } else if characteristic.uuid == UUID_RIDE_CONTROL{
                rideControlCharacteristic = characteristic
                if let command = pendingRideControl {
                    sendRideControl(command)
                    pendingRideControl = nil
                }
            } else if characteristic.uuid == UUID_SENSOR_DATA || characteristic.uuid == UUID_SENSOR_ALERT {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Subscribed to notifications for \(characteristic.uuid)")
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if characteristic.uuid == UUID_SENSOR_DATA || characteristic.uuid == UUID_SENSOR_ALERT {
            if let error = error {
                print("Error receiving data: \(error.localizedDescription)")
                peripheralStatus = .error
                return
            }
            guard let data = characteristic.value else {
                print("No data received for \(characteristic.uuid.uuidString)")
                return
            }
            
            if characteristic.uuid == UUID_SENSOR_DATA {
                if let data = characteristic.value {
                    do {
                        let tempReading = try JSONDecoder().decode(TempSensorReading.self, from: data)
                        
                        if let ride = currentRide {
                            let reading = SensorReading(timestamp: tempReading.timestamp, sensors: tempReading.sensors)
                            reading.ride = ride
                            
                        }
                    } catch {
                        print(" Failed to decode sensor data: \(error)")
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Received JSON: \(jsonString)")
                        }
                    }
                    
                }
                
            } else if characteristic.uuid == UUID_SENSOR_ALERT {
                if let data = characteristic.value,
                   let alertString = String(data: data, encoding: .utf8),
                   let ride = currentRide {
                    
                    print("Received alert string: \(alertString)")
                    
                    let components = alertString.components(separatedBy: ",")
                    
                    if components.count == 3 {
                        let timeComponent = components[0]
                        let poseCodeStr = components[1]
                        let intensityString = components[2]
                        
                        if let timeValue = Double(timeComponent),
                           let intensity = Int(intensityString) {
                            
                            let timestamp: Double
                            if timeValue > 0 {
                                timestamp = timeValue
                            } else {
                                timestamp = Date().timeIntervalSince(ride.startTime)
                            }
                            
                            // Find the alert type
                            for (index, alertType) in AlertType.allCases.enumerated() {
                                if alertType.rawValue == poseCodeStr {
                                    let typeValue = index + 1
                                    
                                    // Create and store the alert
                                    let alert = RideAlert(timestamp: timestamp, type: typeValue, intensity: intensity, ride: ride)
                                    bufferedAlerts.append(alert)
                                    alertHistory.append((timestamp: Date().timeIntervalSince1970, alert: alert))
                                    
                                    break
                                }
                            }
                        } else {
                            print("Invalid alert format: \(alertString)")
                        }
                        
                    }
                }
            }
            
            func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
                if let error = error {
                    print("Error writing to characteristic \(characteristic.uuid): \(error.localizedDescription)")
                }
                else {
                    print("Successfully wrote to characteristic \(characteristic.uuid)")
                }
            }
        }
        
    }
}
