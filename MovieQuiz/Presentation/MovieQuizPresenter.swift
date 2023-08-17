//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Alexey Ponomarev on 16.08.2023.
//

import Foundation
import UIKit


final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService!
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var currentQuestion: QuizQuestion?
    private let questionAmount: Int = 10
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.viewController?.setLoadingIndicator(enabled: true)
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.loadData()
    }
    
    // MARK: QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.setLoadingIndicator(enabled: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func showNetworkError(message: String) {
        viewController?.setLoadingIndicator(enabled: false)

        let alertData = AlertModel(
            title: "Ощибка",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            guard let self = self else { return }

            questionFactory?.loadData()
            self.viewController?.setLoadingIndicator(enabled: true)
            self.resetGame()
        }

        self.viewController?.alertPresenter?.show(data: alertData)
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
    
    func resetGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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
    
    func didAnswer(isCorrect: Bool) {
        if (isCorrect) {
            correctAnswers += 1
        }
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.setButtons(enabled: false)
        proceedWithAnswer(
            isCorrect:  isYes ? currentQuestion.correctAnswer : !currentQuestion.correctAnswer
        )
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQWuestion() {
            let message = makeResultsMessage()
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть еще раз")
            
            viewController?.show(quiz: result)
        } else {
            self.switchToNextQuestion()
            
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrect: isCorrect)
        viewController?.hightlightImageBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.proceedToNextQuestionOrResults()
            self.viewController?.setButtons(enabled: true)
        }
    }
}
