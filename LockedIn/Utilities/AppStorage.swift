//
//  AppStorage.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 12/21/23.
//

import Foundation
import SwiftUI
import ActivityKit

class Time: ObservableObject {
    @AppStorage("hr") var hr = 0
    @AppStorage("min") var min = 0.0
    @AppStorage("pomodoroWork") var pomodoroWork = 25
    @AppStorage("pomodoroBreak") var pomodoroBreak = 5
    @AppStorage("pomodoroNumberOfSessions") var pomodoroNumberOfIntervals = 3
    @AppStorage("pomodoroIntervalCounter") var pomodoroIntervalCounter = 1
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
    @AppStorage("isWorkOn") var isWorkOn = true
    @AppStorage("isTimerPaused") var isTimerPaused = false
    @AppStorage("backgroundMusic") var backgroundMusic = "Rain"
    @AppStorage("selectedItem") var selectedItem = "Simple"
    @AppStorage("snapInterval") var snapInterval = 30.0
    @AppStorage("expectedEndDate") var expectedEndDate = Date()
    @AppStorage("musicFadeTime") var musicFadeTime = 0.5
}
