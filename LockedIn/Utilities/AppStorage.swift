//
//  AppStorage.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 12/21/23.
//

import Foundation
import SwiftUI

class Time: ObservableObject {
    @AppStorage("hr") var hr = 0
    @AppStorage("min") var min = 1
    @AppStorage("pomodoroWork") var pomodoroWork = 25
    @AppStorage("pomodoroBreak") var pomodoroBreak = 5
    @AppStorage("pomodoroNumberOfSessions") var pomodoroNumberOfIntervals = 3
}

class Review: ObservableObject {
    @AppStorage("cycleCount") var cycleCount = 0
}

class Breath: ObservableObject {
    @AppStorage("breaths") var breaths = 5
}

class Settings: ObservableObject {
    @AppStorage("isSnapOn") var isSnapOn = false
    @AppStorage("isMusicOn") var isMusicOn = true
    @AppStorage("isBreathOn") var isBreathOn = true
    @AppStorage("isPomodoroOn") var isPomodoroOn = false
    @AppStorage("backgroundMusic") var backgroundMusic = "Meditation"
    @AppStorage("selectedItem") var selectedItem = "Simple"
    @AppStorage("snapInterval") var snapInterval = 30.0
}
