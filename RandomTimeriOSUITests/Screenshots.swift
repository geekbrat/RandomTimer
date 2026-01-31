//
//  Screenshots.swift
//  RandomTimer
//
//  Created by Kirstyn Plummer on 1/30/26.
//


import XCTest

final class Screenshots: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launchArguments += ["-ui-screenshots"]
    }

    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // Optional: put the app into a predictable state
        // e.g. set a fixed timer range, disable randomness, etc.
        // You can implement this via launch arguments in your app.

        // Snapshot calls are provided by Fastlane's helper (added later)
        snapshot("01_Home")

        // Navigate to Settings
        app.buttons["Settings"].tap()
        snapshot("02_Settings")

        // Navigate to About
        app.buttons["About"].tap()
        snapshot("03_About")
    }
}
