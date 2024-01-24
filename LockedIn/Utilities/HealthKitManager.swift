//
//  HealthKitManager.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 8/31/23.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    private var healthStore = HKHealthStore()

    func requestAuthorization() {
        let typesToWrite: Set<HKSampleType> = [HKObjectType.categoryType(forIdentifier: .mindfulSession)!]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: nil) { success, error in
            if success {
                print("Authorization granted!")
                
            } else {
                if let error = error {
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func saveMindfulMinutes(start: Date, end: Date) {
        let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        let mindfulSample = HKCategorySample(type: mindfulType, value: 0, start: start, end: end)

        healthStore.save(mindfulSample) { success, error in
            if success {
                print("Mindful minutes data saved successfully!")
            } else {
                if let error = error {
                    print("Failed to save mindful minutes data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkAuthorizationStatus(completion: @escaping (HKAuthorizationStatus) -> Void) {
            let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
            let authorizationStatus = healthStore.authorizationStatus(for: mindfulType)
            completion(authorizationStatus)
        }
    
}

