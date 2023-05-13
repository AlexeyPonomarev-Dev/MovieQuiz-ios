//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Alexey Ponomarev on 15.04.2023.
//

import Foundation

struct QuizQuestion: Equatable {
  let image: Data
  let text: String
  let correctAnswer: Bool
}
