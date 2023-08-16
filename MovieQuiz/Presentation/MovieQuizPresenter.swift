//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Alexey Ponomarev on 16.08.2023.
//

import Foundation
import UIKit


final class MovieQuizPresenter {
    let questionAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let index = currentQuestionIndex + 1
        let questionNumber = "\(index)/\(questionAmount)"
        
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: questionNumber)
    }
    
    func isLastQWuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func noButtonPress() {
        guard let currentQuestion = currentQuestion else { return }
    
        viewController?.setButtons(enabled: false)
        viewController?.showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }

    func yesButtonPress() {
        guard let currentQuestion = currentQuestion else { return }
        
        viewController?.setButtons(enabled: false)
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
}
