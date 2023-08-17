//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Alexey Ponomarev on 15.04.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var meddleRating: Double = 0
    
    private var movies: [MostPopularMovie] = []
    

//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        ),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        ),
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        ),
//        QuizQuestion(
//            image: "Vivarium",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        ),
//    ]
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.meddleRating = self.getMeddleRating(from: mostPopularMovies.items)
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                 imageData = try Data(contentsOf: movie.resizedImageURL)

             } catch {
                 DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
             
                    self.delegate?.showNetworkError(message: "Failed to load image")
                 }
             }
             
            let rating = Double(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем \(self.meddleRating)?"
            let correctAnswer = rating > self.meddleRating
             
             let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
             
             DispatchQueue.main.async { [weak self] in
                 guard let self = self else { return }
                 self.delegate?.didReceiveNextQuestion(question: question)
             }
         }
    }
    
    private func getMeddleRating(from movies: [MostPopularMovie]) -> Double {
        let sum = movies.reduce(0) { partialResult, movie in
            partialResult + (Double(movie.rating) ?? 0)
        }
        let double = sum / Double(movies.count)
        let doubleStr = String(format: "%.1f", double)

        return Double(doubleStr) ?? 0
   }
}
