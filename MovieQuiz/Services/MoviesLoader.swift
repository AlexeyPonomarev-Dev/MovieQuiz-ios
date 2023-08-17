//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Alexey Ponomarev on 08.05.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let jsonDecoder = JSONDecoder()
    private let networkClient = NetworkClient()
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_r87sbv12") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { response in
            switch response {
            case .success(let data):
                do {
                    let mostPopularMovies = try jsonDecoder.decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                    
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
            
        }
    }
}
