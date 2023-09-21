//
//  DetailMovieInformation.swift
//  BoxOffice
//
//  Created by Rhode, Rilla on 2023/03/21.
//

struct DetailMovieInformation: Decodable {
    let movieInformationResult: MovieInformationResult
    
    private enum CodingKeys: String, CodingKey {
        case movieInformationResult = "movieInfoResult"
    }
}
