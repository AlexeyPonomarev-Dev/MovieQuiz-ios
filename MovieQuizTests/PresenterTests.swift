//
//  PresenterTests.swift
//  MovieQuizTests
//
//  Created by Alexey Ponomarev on 17.08.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var alertPresenter: MovieQuiz.AlertPresenter?
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {}
    
    func show(quiz result: MovieQuiz.QuizResultsViewModel) {}
    
    func hightlightImageBorder(isCorrect: Bool) {}
    
    func setLoadingIndicator(enabled: Bool) {}
    
    func setButtons(enabled: Bool) {}

}

final class PresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
        
    }
}
