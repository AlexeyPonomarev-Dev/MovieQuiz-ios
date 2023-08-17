//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Alexey Ponomarev on 17.08.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    var alertPresenter: AlertPresenter? { get }

    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func hightlightImageBorder(isCorrect: Bool)
    func setLoadingIndicator(enabled: Bool)
    func setButtons(enabled: Bool)
}
