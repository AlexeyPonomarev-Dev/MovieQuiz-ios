//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Alexey Ponomarev on 03.08.2023.
//

import XCTest
@testable import MovieQuiz


class ArrayTests: XCTestCase {
    func testGetValuenRange() {
        // Given
        let array = [1, 2, 3, 4, 5]
        let index = 2
        
        // When
        let element = array[safe: index]
        
        // Then
        XCTAssertNotNil(element)
        XCTAssertEqual(element, 3)
    }
    
    func testGetValueOutOfrange() {
        // Given
        let array = [1, 2, 3, 4, 5]
        let index = 20
        
        // When
        let element = array[safe: index]
        
        // Then
        XCTAssertNil(element)
    }
}
