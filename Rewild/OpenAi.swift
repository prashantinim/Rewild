
//
//  OpenAi.swift
//  Rewild
//
//  Created by Prashantini Maniam on 24/11/2023.
//
import OpenAISwift
import Foundation

final class APICaller {
    static let shared = APICaller()

    private var client: OpenAISwift?

    private init() {
        setup()
    }

    private func setup() {
        self.client = createClient(withKey: "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") // Replace with your actual API key
    }

    private func createClient(withKey apiKey: String) -> OpenAISwift {
        let config = OpenAISwift.Config.makeDefaultOpenAI(apiKey: apiKey)
        return OpenAISwift(config: config)
    }

    public func switchAPIKey(newKey: String) {
        self.client = createClient(withKey: newKey)
    }
    
    public func getPlantRecommendations(plantType: String, plantSize: String, flowerColor: String, completion: @escaping (Result<String, Error>) -> Void) {
        let query = "Get me three plants that best match these requirements: " +
                    "plant_type:\(plantType) AND " +
                    "plant_size:\(plantSize) AND " +
                    "flower_color:\(flowerColor)"

        client?.sendCompletion(with: query, completionHandler: { result in
            switch result {
            case .success(let model):
                guard let output = model.choices?.first?.text else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No text in response"])))
                    return
                }
                completion(.success(output))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
