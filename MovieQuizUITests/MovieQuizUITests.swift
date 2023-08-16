//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Alexey Ponomarev on 06.08.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()
        
        // если один тест не прошел то следующие запускаться не будут
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        
        // получаем скриншот элемента и преобразовываем его в тип Data
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        
        // получаем скриншот элемента и преобразовываем его в тип Data
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        
        // получаем скриншот элемента и преобразовываем его в тип Data
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        app.buttons["No"].tap()
        
        sleep(3)
        let secondPoster = app.images["Poster"]
        
        // получаем скриншот элемента и преобразовываем его в тип Data
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testResultAlert() {
        sleep(2)

        for _ in 0..<10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Alert"]
        let alertLabel = alert.label
        let alertButtonLabel = alert.buttons.firstMatch.label
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alertLabel, "Этот раунд окончен!")
        XCTAssertEqual(alertButtonLabel, "Сыграть еще раз")
    }
    
    func testAlertDismiss() {
        sleep(2)

        for _ in 0..<10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Alert"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
