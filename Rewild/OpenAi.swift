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

        // Split the responseText into individual names, assuming it's comma-separated
        let plantNames = responseText.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        for name in plantNames {
            let choice = Choice(
                id: UUID().uuidString,
                locationID: LocationID.the0F92C001Ddc5D67Bec3Dfc4Caed49Ca1, // Example default value
                scientificName: name,
                commonName: "Default Common Name", // Placeholder
                family: "Default Family", // Placeholder
                kingdom: Kingdom.plantae, // Example default value
                count: 1, // Placeholder
                state: UserState.nsw, // Example default value
                postcode: 12345, // Placeholder
                speciesID: 1, // Placeholder
                plantType: PlantType.shrub, // Example default value
                plantOrigin: "Default Origin", // Placeholder
                lightRequirement: LightRequirement.fullSun, // Example default value
                windTolerance: WindTolerance.sheltered, // Example default value
                growthRate: GrowthRate.medium, // Example default value
                frostResistant: FrostResistant.hardy, // Example default value
                isEvergreen: false, // Placeholder
                isNative: true, // Placeholder
                plantHeight: PlantHeight.the15M, // Example default value
                plantWidth: 1.0, // Placeholder
                plantSize: PlantSize.medium, // Example default value
                flowerColor: FlowerColor(rawValue: "Color") ?? .white,
                occurrenceByState: "Default Occurrence", // Placeholder
                floweringMonth: "Default Month", // Placeholder
                climateZone: "Default Zone", // Placeholder
                isIntroducedAct: false, // Placeholder
                isIntroducedTas: false, // Placeholder
                isIntroducedWa: false, // Placeholder
                isIntroducedVic: false, // Placeholder
                isIntroducedQld: false, // Placeholder
                isIntroducedNsw: false, // Placeholder
                isIntroducedSa: false, // Placeholder
                isIntroducedNT: false, // Placeholder
                imageURL: "Default URL", // Placeholder
                summary: "Default Summary" // Placeholder
            )
            choices.append(choice)
        }
        return choices
    }



    func getPlantRecommendations(state: String, postcode: String, plantType: String, plantSize: String, flowerColor: String, plantHeight: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let query = "List three native plants from the region with state: \(state) and postcode: \(postcode) that match these requirements: plant type \(plantType), plant size \(plantSize), flower color \(flowerColor), plant height \(plantHeight)."

    

        // Inside getPlantRecommendations function
        client?.sendCompletion(with: query, completionHandler: { result in
            switch result {
            case .success(let model):
                guard let choices = model.choices else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No choices in response"])))
                    return
                }

                let plantNames = choices.compactMap { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
                completion(.success(plantNames))

            case .failure(let error):
                completion(.failure(error))
            }
        })

    }
}
