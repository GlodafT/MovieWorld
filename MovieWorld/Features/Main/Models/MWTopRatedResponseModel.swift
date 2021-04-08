//
//  MWTopRatedResponseModel.swift
//  MovieWorld
//
//  Created by Mikita Igonin on 7.04.21.
//

import Foundation

struct MWTopRatedResponseModel: Decodable {
    let page: Int
    let results: [MWMovie]
    let total_results: Int
    let total_pages: Int
}
