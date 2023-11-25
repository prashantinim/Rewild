
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
                flowerColor: "Default Color", // Placeholder
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



    public func getPlantRecommendations(state: String, postcode: String, plantType: String, plantSize: String, flowerColor: String, plantHeight: String, completion: @escaping (Result<[Choice], Error>) -> Void) {
        let query = "Get me three native plants from the region with state: \(state) and postcode: \(postcode) that best match these requirements: " +
        "plant_type:\(plantType), " +
        "plant_size:\(plantSize), " +
        "flower_color:\(flowerColor), " +
        "plant_height:\(plantHeight)"
    

        client?.sendCompletion(with: query, completionHandler: { result in
                    switch result {
                    case .success(let model):
                        // Check if there are choices in the response
                        guard let choices = model.choices else {
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No choices in response"])))
                            return
                        }
                        
                        let parsedChoices = choices.map { choice -> Choice in
                            let uniqueID = UUID().uuidString
                                
                                // Fill in the properties based on your parsing logic
                                let locationID = LocationID.the0F92C001Ddc5D67Bec3Dfc4Caed49Ca1 // Example default value
                                let scientificName = choice.text
                                let commonName = "Default Common Name" // Placeholder
                                let family = "Default Family" // Placeholder
                                let kingdom = Kingdom.plantae // Example default value
                                let count = 1 // Placeholder
                                let state = UserState.nsw // Example default value
                                let postcode = 12345 // Placeholder
                                let speciesID = 1 // Placeholder
                                let plantType = PlantType.shrub // Example default value
                                let plantOrigin = "Default Origin" // Placeholder
                                let lightRequirement = LightRequirement.fullSun // Example default value
                                let windTolerance = WindTolerance.sheltered // Example default value
                                let growthRate = GrowthRate.medium // Example default value
                                let frostResistant = FrostResistant.hardy // Example default value
                                let isEvergreen = false // Placeholder
                                let isNative = true // Placeholder
                                let plantHeight = PlantHeight.the15M // Example default value
                                let plantWidth = 1.0 // Placeholder
                                let plantSize = PlantSize.medium // Example default value
                                let flowerColor = "Default Flower Color" // Placeholder
                                let occurrenceByState = "Default Occurrence" // Placeholder
                                let floweringMonth = "Default Month" // Placeholder
                                let climateZone = "Default Climate Zone" // Placeholder
                                let isIntroducedAct = false // Placeholder
                                let isIntroducedTas = false // Placeholder
                                let isIntroducedWa = false // Placeholder
                                let isIntroducedVic = false // Placeholder
                                let isIntroducedQld = false // Placeholder
                                let isIntroducedNsw = false // Placeholder
                                let isIntroducedSa = false // Placeholder
                                let isIntroducedNT = false // Placeholder
                                let imageURL = "Default Image URL" // Placeholder
                                let summary = "Default Summary" // Placeholder

                                // Create and return a Choice instance with the filled properties
                                return Choice(
                                    id: uniqueID,
                                    locationID: locationID,
                                    scientificName: scientificName,
                                    commonName: commonName,
                                    family: family,
                                    kingdom: kingdom,
                                    count: count,
                                    state: state,
                                    postcode: postcode,
                                    speciesID: speciesID,
                                    plantType: plantType,
                                    plantOrigin: plantOrigin,
                                    lightRequirement: lightRequirement,
                                    windTolerance: windTolerance,
                                    growthRate: growthRate,
                                    frostResistant: frostResistant,
                                    isEvergreen: isEvergreen,
                                    isNative: isNative,
                                    plantHeight: plantHeight,
                                    plantWidth: plantWidth,
                                    plantSize: plantSize,
                                    flowerColor: flowerColor,
                                    occurrenceByState: occurrenceByState,
                                    floweringMonth: floweringMonth,
                                    climateZone: climateZone,
                                    isIntroducedAct: isIntroducedAct,
                                    isIntroducedTas: isIntroducedTas,
                                    isIntroducedWa: isIntroducedWa,
                                    isIntroducedVic: isIntroducedVic,
                                    isIntroducedQld: isIntroducedQld,
                                    isIntroducedNsw: isIntroducedNsw,
                                    isIntroducedSa: isIntroducedSa,
                                    isIntroducedNT: isIntroducedNT,
                                    imageURL: imageURL,
                                    summary: summary

                            )
                        }
                        
                        completion(.success(parsedChoices))
                    case .failure(let error):
                        completion(.failure(error))
            }
        })

    }
}
