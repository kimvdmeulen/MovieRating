//
//  ApiConnectionProtocol.swift
//  MovieRating
//
//  Created by nick huegen on 10/01/2022.
//

import Foundation

protocol ApiConnectionProtocol {
    func ConnectOMDB(movie: String) -> MovieRating
}
