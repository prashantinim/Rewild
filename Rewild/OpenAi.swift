
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
    
    private func parseResponseToChoices(_ responseText: String) -> [Choice] {
            var choices = [Choice]()

            // Implement the actual parsing logic here
            // Convert the responseText into an array of Choice objects
            // Depending on the format of the response text, this might involve parsing JSON,
            // extracting information from a string, etc.

            return choices
        }
    
    public func getPlantRecommendations(state: String, postcode: String, plantType: String, plantSize: String, flowerColor: String, plantHeight: String, completion: @escaping (Result<[Choice], Error>) -> Void) {
        let query = "Get me three native plants from the region with state: \(state) and postcode: \(postcode) that best match these requirements: " +
        "plant_type:\(plantType), " +
        "plant_size:\(plantSize), " +
        "flower_color:\(flowerColor), " +
        "plant_height:\(plantHeight)"
    

        client?.sendCompletion(with: query, completionHandler: { result in
            switch result {
            case .success(let model):
                guard let responseText = model.choices?.first?.text else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No text in response"])))
                    return
                }
                // Parse the responseText into an array of Choice objects
                let parsedChoices = self.parseResponseToChoices(responseText)
                completion(.success(parsedChoices))
            case .failure(let error):
                completion(.failure(error))
            }
        })

    }
}
