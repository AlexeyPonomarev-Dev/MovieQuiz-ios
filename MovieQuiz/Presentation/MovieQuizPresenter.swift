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
    
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = 0
    
    weak var viewController: MovieQuizViewController?
    
    private var currentQuestionIndex: Int = 0
    
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
        didAnswer(isYes: false)
    }

    func yesButtonPress() {
        didAnswer(isYes: true)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.setButtons(enabled: false)
        viewController?.showAnswerResult(
            isCorrect:  isYes ? currentQuestion.correctAnswer : !currentQuestion.correctAnswer
        )
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if isLastQWuestion() {
            viewController?.statisticService?.store(correct: correctAnswers, total: questionAmount)
        
            guard let record = viewController?.statisticService?.bestGame,
                  let gamesCount = viewController?.statisticService?.gamesCount,
                  let acuracy = viewController?.statisticService?.totalAccuracy else {
                return
            }

            let message = "Ваш результат: \(correctAnswers)/\(questionAmount)\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(record.correct)/\(record.total) (\(record.date))\nСредняя точность: \(String(format: "%.2f", acuracy))%"
            
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть еще раз")
            
            viewController?.show(quiz: result)
        } else {
            self.switchToNextQuestion()
            
            self.viewController?.questionFactory?.requestNextQuestion()
        }
    }
}
