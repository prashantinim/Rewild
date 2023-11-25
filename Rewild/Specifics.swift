//
//  Specifics.swift
//  Rewild
//
//  Created by Prashantini Maniam on 24/11/2023.
//

import Foundation

// MARK: - Temperature
struct Choice: Codable, Identifiable {
    let id: String  // GUID as unique identifier
    let locationID: LocationID
    let scientificName, commonName, family: String
    let kingdom: Kingdom
    let count: Int
    let state: UserState
    let postcode: Int
    let speciesID: Int
    let plantType: PlantType
    let plantOrigin: String
    let lightRequirement: LightRequirement
    let windTolerance: WindTolerance
    let growthRate: GrowthRate
    let frostResistant: FrostResistant
    let isEvergreen, isNative: Bool
    let plantHeight: PlantHeight
    let plantWidth: Double
    let plantSize: PlantSize
    let flowerColor: FlowerColor
    let occurrenceByState, floweringMonth, climateZone: String
    let isIntroducedAct, isIntroducedTas, isIntroducedWa, isIntroducedVic: Bool
    let isIntroducedQld, isIntroducedNsw, isIntroducedSa, isIntroducedNT: Bool
    let imageURL, summary: String

    enum CodingKeys: String, CodingKey {
        case id = "guid"
        case locationID = "location_id"
        case scientificName = "scientific_name"
        case commonName = "common_name"
        case family, kingdom, count
        case state = "UserState"
        case postcode = "Postcode"
        case speciesID = "species_id"
        case plantType = "plant_type"
        case plantOrigin = "plant_origin"
        case lightRequirement = "light_requirement"
        case windTolerance = "wind_tolerance"
        case growthRate = "growth_rate"
        case frostResistant = "frost_resistant"
        case isEvergreen = "is_evergreen"
        case isNative = "is_native"
        case plantHeight = "plant_height"
        case plantWidth = "plant_width"
        case plantSize = "plant_size"
        case flowerColor = "flower_color"
        case occurrenceByState = "occurrence_by_state"
        case floweringMonth = "flowering_month"
        case climateZone = "climate_zone"
        case isIntroducedAct = "is_introduced_act"
        case isIntroducedTas = "is_introduced_tas"
        case isIntroducedWa = "is_introduced_wa"
        case isIntroducedVic = "is_introduced_vic"
        case isIntroducedQld = "is_introduced_qld"
        case isIntroducedNsw = "is_introduced_nsw"
        case isIntroducedSa = "is_introduced_sa"
        case isIntroducedNT = "is_introduced_nt"
        case imageURL = "Image URL"
        case summary = "Summary"
    }
}

enum FrostResistant: String, Codable {
    case hardy = "Hardy"
    case marginal = "Marginal"
    case tender = "Tender"
}


enum GrowthRate: String, Codable {
    case fast = "Fast"
    case medium = "Medium"
    case slow = "Slow"
    case veryFast = "Very fast"
}

enum Kingdom: String, Codable {
    case plantae = "Plantae"
}

enum LightRequirement: String, Codable {
    case fullSun = "Full Sun"
    case fullSunToPartShade = "Full Sun to Part Shade"
    case halfSunHalfShade = "Half Sun / Half Shade"
    case moderateDappledShade = "Moderate/Dappled Shade"
}

enum LocationID: String, Codable {
    case the0F92C001Ddc5D67Bec3Dfc4Caed49Ca1 = "0f92c001ddc5d67bec3dfc4caed49ca1"
    case the3Dd1Ed7A6Ab8F926D674Dd3C485179C4 = "3dd1ed7a6ab8f926d674dd3c485179c4"
}

enum PlantHeight: String, Codable, CaseIterable {
    case the01M = "0-1m"
    case the1020M = "10-20m"
    case the15M = "1-5m"
    case the2030M = "20-30m"
    case the30M = ">30m"
    case the510M = "5-10m"
}

enum PlantSize: String, Codable, CaseIterable {
    case large = "Large"
    case medium = "Medium"
    case others = "Others"
    case small = "Small"
}

enum PlantType: String, Codable, CaseIterable {
    case annualPerennial = "Annual/Perennial"
    case others = "Others"
    case shrub = "Shrub"
    case tree = "Tree"
}


enum UserState: String, Codable, CaseIterable {
    case nsw = "NSW"
    case vic = "VIC"
    // Add other states as needed
}

enum UserPostcode: String, Codable, CaseIterable {
    case nsw2084 = "2084"
    case vic3249 = "3249"
    // Add other postcodes as needed
}

enum WindTolerance: String, Codable {
    case medium = "Medium"
    case sheltered = "Sheltered"
    case windSaltTolerant = "Wind/Salt tolerant"
    case windTolerant = "Wind Tolerant"
}

typealias Temperatures = [Choice]

extension Bundle {
    func decode<T: Decodable>(file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Could not find \(file) in the project!")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(file) in the project!")
        }
        
        let decoder = JSONDecoder()

        do {
            let loadedData = try decoder.decode(T.self, from: data)
            return loadedData
        } catch {
            fatalError("Could not decode \(file) in the project! Error: \(error)")
        }
    }
}

