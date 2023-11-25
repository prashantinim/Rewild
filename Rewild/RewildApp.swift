//
//  RewildApp.swift
//  Rewild
//
//  Created by Prashantini Maniam on 24/11/2023.
//
import SwiftUI
import Combine
import WebKit
import CoreLocation


@main
struct PlantRecommenderApp: App {
    @StateObject var viewModel = PlantViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}


struct ContentView: View {
    var body: some View {
        NavigationView {
            LoginView()
        }
    }
}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isAuthenticated: Bool = false
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Login") {
                isAuthenticated = true
            }
            .padding()
            
            if isAuthenticated {
                NavigationLink(destination: MainTabView(), isActive: $isAuthenticated) {
                    EmptyView()
                }
            }
        }
    }
}


// MainTabView
struct MainTabView: View {
    var body: some View {
        TabView {
            UserProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }

            // Navigating to UserLocationView instead of PreferencesView
            UserLocationView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}

struct UserProfileView: View {
    @State private var username: String = "Username"
    @State private var plantsCultivatedCount: Int = 0
    @State private var newPlantName: String = ""
    @State private var newPlantCount: Int = 0
    @State private var plantsWishlist: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Welcome \(username)!")
                    .font(.title)
                    .padding()

                // Removed preferences section

                Divider()

                VStack {
                    Text("Track Your Cultivation Progress")
                        .font(.headline)
                        .padding()

                    Text("Plants Cultivated: \(plantsCultivatedCount)")

                    TextField("Enter Plant Name", text: $newPlantName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Stepper("Number of Plants: \(newPlantCount)", value: $newPlantCount, in: 0...100)
                        .padding()

                    Button("Add Plant") {
                        plantsCultivatedCount += newPlantCount
                        newPlantName = ""
                        newPlantCount = 0
                    }
                    .padding()

                    Divider()

                    VStack {
                        Text("Your Plants Wishlist")
                            .font(.headline)
                            .padding()

                        ForEach(plantsWishlist, id: \.self) { plant in
                            Text(plant)
                        }

                        Button("Add to Wishlist") {
                            // Add logic to add plants to the wishlist
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Your Profile", displayMode: .inline)
    }
}


enum FlowerColor: String, Codable {
    case white = "White"
    case Blue = "Blue"
    case yellow = "Yellow"
}
struct UserLocationView: View {
    @State private var userState: UserState? = nil
    @State private var userPostcode: UserPostcode? = nil// Default enum case
    @ObservedObject var viewModel = PlantViewModel()
    @State private var preferredFloweringColor: FlowerColor = .white

        
    // Default value
    @State private var preferredPlantType: PlantType = .shrub // Default value, adjust as needed
    @State private var preferredPlantSize: PlantSize = .medium // Default value, adjust as needed
    @State private var preferredPlantHeight: PlantHeight = .the15M // Default value, adjust as needed

        
    @State private var showResults = false

    var body: some View {
        Form {
            Section(header: Text("Your Location")) {
                Picker("State", selection: $userState) {
                    Text("Select a state").tag(UserState?.none) // Optional for 'none' selection
                    ForEach(UserState.allCases, id: \.self) { state in
                        Text(state.rawValue).tag(state as UserState?)
                    }
                }

                .pickerStyle(MenuPickerStyle())

                Picker("Postcode", selection: $userPostcode) {
                    ForEach(UserPostcode.allCases, id: \.self) { postcode in
                        Text(postcode.rawValue).tag(postcode.rawValue)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Section(header: Text("Select Your Preferences")) {
                // Plant Size Picker
                Picker("Plant Size", selection: $preferredPlantSize) {
                    ForEach(PlantSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }

                // Flowering Color Picker
                Picker("Flowering Color", selection: $preferredFloweringColor) {
                    ForEach(viewModel.floweringColors, id: \.self) { color in
                        Text(color).tag(color)
                    }
                }

                // Plant Type Picker
                Picker("Plant Type", selection: $preferredPlantType) {
                    ForEach(PlantType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }

                // Plant Height Picker
                Picker("Plant Height", selection: $preferredPlantHeight) {
                    ForEach(PlantHeight.allCases, id: \.self) { height in
                        Text(height.rawValue).tag(height)
                    }
                }

            }

            Section(header: Text("Find Plants")) {
                Button("Find Plants") {
                    showResults = true
                    viewModel.fetchOpenAIPlantRecommendations(
                        state: userState!.rawValue,
                        postcode: userPostcode!.rawValue,
                        plantType: preferredPlantType, // Directly using the enum-typed variable
                        plantSize: preferredPlantSize, // Directly using the enum-typed variable
                        flowerColor: preferredFloweringColor.rawValue, // Assuming this is a String
                        plantHeight: preferredPlantHeight // Directly using the enum-typed variable
                    )
                }


                if viewModel.isLoading {
                    ProgressView("Loading...")
                }
            }
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK")) {
                    viewModel.showError = false // Close the alert after OK is tapped
                }
            )
        }
    }
}

class PlantViewModel: ObservableObject {
        @Published var choices: [Choice] = []
        @Published var recommendedPlants: [Choice] = []
        @Published var requirements: String = ""
        @Published var careInfo: String = ""
        @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @StateObject var viewModel = PlantViewModel()
        
        var states: [String] {
            Array(Set(choices.map { $0.state.rawValue })).sorted()
        }
        var plantSizes: [String] {
            Array(Set(choices.map { $0.plantSize.rawValue })).sorted()
        }
       
        var floweringColors: [String] {
            Array(Set(choices.map { $0.flowerColor.rawValue })).sorted()
        }
        var plantHeights: [String] {
            Array(Set(choices.map { $0.plantHeight.rawValue })).sorted()
        }
        var plantTypes: [String] {
            Array(Set(choices.map { $0.plantType.rawValue })).sorted()
        }
        
        init() {
            loadChoices()
        }
        
        private func loadChoices() {
            // Load choices from a JSON file
            // This function needs to be implemented according to how you store or retrieve data
            self.choices = Bundle.main.decode(file: "new.json")
        }
        
        func filterPlants(state: String, plantSize: String, flowerColor: String, plantHeight: String, plantType: String) {
            recommendedPlants = choices.filter { choice in
                (state == "State" || choice.state.rawValue == state) &&
                (plantSize == "Plant Size" || choice.plantSize.rawValue == plantSize) &&
                (flowerColor == "Flowering Color" || choice.flowerColor.rawValue == flowerColor) &&

                (plantHeight == "Plant Height" || choice.plantHeight.rawValue == plantHeight) &&
                (plantType == "Plant Type" || choice.plantType.rawValue == plantType)
            }
        }
        
        func fetchImageURL(for plantName: String, completion: @escaping (URL?) -> Void) {
            let formattedPlantName = plantName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "https://en.wikipedia.org/w/api.php?action=query&titles=\(formattedPlantName)&prop=pageimages&format=json&pithumbsize=500"
            
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(WikipediaImageResult.self, from: data)
                    let pageId = result.query.pages.keys.first ?? ""
                    let imageUrl = result.query.pages[pageId]?.thumbnail?.source
                    completion(URL(string: imageUrl ?? ""))
                } catch {
                    completion(nil)
                }
            }.resume()
        }
        
    func fetchOpenAIPlantRecommendations(state: String, postcode: String, plantType: PlantType, plantSize: PlantSize, flowerColor: String, plantHeight: PlantHeight) {
            isLoading = true
            let plantTypeString = plantType.rawValue
            let plantSizeString = plantSize.rawValue
            let plantHeightString = plantHeight.rawValue

            APICaller.shared.getPlantRecommendations(state: state, postcode: postcode, plantType: plantTypeString, plantSize: plantSizeString, flowerColor: flowerColor, plantHeight: plantHeightString) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let plantNames):
                        // Convert plantNames to Choices and assign to recommendedPlants
                        // You need to modify this logic based on how you want to handle the results
                        self?.recommendedPlants = plantNames.map { name in
                            Choice(id: UUID().uuidString, locationID: .the0F92C001Ddc5D67Bec3Dfc4Caed49Ca1, scientificName: name, commonName: "Common Name", family: "Family", kingdom: .plantae, count: 1, state: .nsw, postcode: 12345, speciesID: 1, plantType: .shrub, plantOrigin: "Origin", lightRequirement: .fullSun, windTolerance: .sheltered, growthRate: .medium, frostResistant: .hardy, isEvergreen: false, isNative: true, plantHeight: .the15M, plantWidth: 1.0, plantSize: .medium, flowerColor: FlowerColor(rawValue: "Color") ?? .white, occurrenceByState: "Occurrence", floweringMonth: "Month", climateZone: "Zone", isIntroducedAct: false, isIntroducedTas: false, isIntroducedWa: false, isIntroducedVic: false, isIntroducedQld: false, isIntroducedNsw: false, isIntroducedSa: false, isIntroducedNT: false, imageURL: "URL", summary: "Summary")
                        }
                    case .failure(let error):
                        self?.handleErrorResponse(error)
                    }
                }
            }
    }
    
    private func handleSuccessfulResponse(_ plantNames: [String]) {
            // Logic to handle successful response, such as updating UI
    }

    private func handleErrorResponse(_ error: Error) {
            // Logic to handle error response, such as showing an alert
    }
        
    func fetchPlantCareInfo(for plantName: String) {
            let query = "Get me care information for the plant: \(plantName)"
            
            sendOpenAIRequest(with: query) { response in
                DispatchQueue.main.async {
                    self.requirements = response.requirements
                    self.careInfo = response.careInfo
                }
            }
    }
        
    private func sendOpenAIRequest(with query: String, completion: @escaping (OpenAIResponse) -> Void) {
            let url = URL(string: "https://api.openai.com/v1/engines/davinci/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = ["prompt": query, "max_tokens": 100]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                        completion(decodedResponse)
                    } catch {
                        print("Failed to decode response: \(error)")
                    }
                }
            }.resume()
}
    
    var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(viewModel)
            }
        }
}

    
struct WikipediaImageResult: Codable {
        let query: Query
}
    
struct Query: Codable {
        let pages: [String: Page]
}
    
struct Page: Codable {
        let thumbnail: Thumbnail?
    }
    
struct Thumbnail: Codable {
        let source: String
}
    
struct OpenAIResponse: Decodable {
        var choices: [Choice]
        var requirements: String
        var careInfo: String
}
    
    
class ImageLoader: ObservableObject {
        @Published var image: Image?
        
        func loadImage(fromURL url: URL) {
            URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .compactMap { UIImage(data: $0) }
                .map { Image(uiImage: $0) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .assign(to: &$image)
        }
        
}
    
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
        private let locationManager = CLLocationManager()
        
        override init() {
            super.init()
            locationManager.delegate = self
        }
        
        func requestLocationPermission() {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // Implement CLLocationManagerDelegate methods to handle location updates
        // ...
}
    
    // Define a structure for plant preferences
struct PlantPreferences {
        var type: String
        var size: String
        var color: String
}
    
    
struct PlantPreferencesView: View {
        @ObservedObject var viewModel = PlantViewModel()
        
        var state: String
        var postcode: String
        
        var body: some View {
            // Example of a view body
            VStack {
                Text("Your selected state is \(state)")
                Text("Your postcode is \(postcode)")
            }
        }
}
    
    
    // Row in CriteriaSelectionView for multiple selection
struct MultipleSelectionRow: View {
        var title: String
        var isSelected: Bool
        var action: () -> Void
        
        var body: some View {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
        }
}
    
    // LoginView
    
    
    
    // Rest of your code remains the same
    
    
struct ProfileCustomizationView: View {
        @Binding var username: String
        @Binding var bio: String
        @Binding var favoritePlantType: String
        @Binding var profileImage: Image
        
        var body: some View {
            Form {
                Section(header: Text("Profile Picture")) {
                    // Add logic for handling profile image change
                }
                Section(header: Text("Username")) {
                    TextField("Username", text: $username)
                }
                Section(header: Text("Bio")) {
                    TextField("Bio", text: $bio)
                }
                Section(header: Text("Favorite Plant Type")) {
                    TextField("Favorite Plant Type", text: $favoritePlantType)
                }
            }
            .navigationBarTitle("Edit Profile")
        }
}
    
struct UserDashboardView: View {
        @State private var plantsOwned: Int = 0
        @State private var plantsWishlist: [String] = []
        @State private var gardeningMilestones: [String] = []
        
        var body: some View {
            ScrollView {
                VStack {
                    Text("Plants Owned: \(plantsOwned)")
                        .padding()
                    
                    Text("Plants Wishlist")
                    List(plantsWishlist, id: \.self) { plant in
                        Text(plant)
                    }
                    
                    Text("Gardening Milestones")
                    List(gardeningMilestones, id: \.self) { milestone in
                        Text(milestone)
                    }
                }
            }
            .navigationBarTitle("Dashboard")
        }
}
    
    
    // HistoryView for displaying the history of viewed plants
struct HistoryView: View {
        @Binding var viewedPlants: [String]
        
        var body: some View {
            List(viewedPlants, id: \.self) { plant in
                Text(plant)
            }
            .navigationBarTitle("Viewed Plants History", displayMode: .inline)
        }
}
        
    // PlantImageView definition
struct PlantImageView: View {
        let imageURL: URL?
        @ObservedObject private var imageLoader = ImageLoader()
        
        var body: some View {
            Group {
                if let imageURL = imageURL {
                    imageLoader.image?
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(8)
                        .onAppear {
                            imageLoader.loadImage(fromURL: imageURL)
                        }
                } else {
                    Text("Image not available")
                        .font(.title)
                        .padding()
                }
            }
        }
}
    
    
    
    
    // WebView definition
struct WebView: UIViewRepresentable {
        var url: URL
        
        func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.navigationDelegate = context.coordinator
            return webView
        }
        
        func updateUIView(_ webView: WKWebView, context: Context) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, WKNavigationDelegate {
            var parent: WebView
            
            init(_ parent: WebView) {
                self.parent = parent
            }
        }
}
    
struct ResultsView: View {
    @ObservedObject var viewModel: PlantViewModel
        
    var body: some View {
            Group {
                if viewModel.recommendedPlants.isEmpty {
                    Text("No plants found")
                        .padding()
                } else {
                    List(viewModel.recommendedPlants, id: \.id) { plant in
                        VStack(alignment: .leading) {
                            Text(plant.scientificName)
                            // Add more details as needed
                        }
                    }
                    .navigationBarTitle("Recommended Plants")
            }
        }
    }
                 
}
    
    // Ensure that you have the ImageLoader class defined as in your previous code
struct SummaryView: View {
        var selectedPlant: Choice
        var viewModel: PlantViewModel
        var wikipediaURL: URL
        
        @StateObject private var imageLoader = ImageLoader()
        @StateObject private var locationManager = LocationManager()
        
        var body: some View {
            ScrollView {
                VStack {
                    WebView(url: wikipediaURL)
                        .frame(maxWidth: .infinity, maxHeight: 400)
                    
                    if let image = imageLoader.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } else {
                        Text("Loading image...")
                            .onAppear {
                                viewModel.fetchImageURL(for: selectedPlant.scientificName) { url in
                                    if let url = url {
                                        imageLoader.loadImage(fromURL: url)
                                    }
                                }
                            }
                    }
                    
                    Text(selectedPlant.scientificName)
                        .font(.title)
                    
                    Text(selectedPlant.commonName)
                        .font(.subheadline)
                        .padding(.bottom, 5)
                    
                    Text(selectedPlant.summary)
                        .font(.body)
                        .padding()
                    
                    Text("Requirements:")
                        .font(.headline)
                    Text(viewModel.requirements)
                        .font(.body)
                        .padding()
                    
                    Text("Care:")
                        .font(.headline)
                    Text(viewModel.careInfo)
                        .font(.body)
                        .padding()
                    
                    Button("Buy This Plant") {
                        // Action to find nearby nurseries based on current location
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                }
            }
            .onAppear {
                locationManager.requestLocationPermission()
            }
        }
}
    
    
    // PlantCareView placeholder (replace with actual view)
struct PlantCareView: View {
        var body: some View {
            Text("Plant Care Information")
        }
}
    
    // Renaming the second PreferencesView to avoid duplicate declaration
struct PlantCriteriaSelectionView: View {
    @State private var selectedCriteria = Set<String>()
    let availableCriteria = ["Flower Color", "Frost Resistance", "Wind Tolerance", "Plant Size", "Plant Type"]
    
    var body: some View {
        Form {
            Section(header: Text("Select Criteria")) {
                List(availableCriteria, id: \.self) { criteria in
                    MultipleSelectionRow(title: criteria, isSelected: selectedCriteria.contains(criteria)) {
                        if selectedCriteria.contains(criteria) {
                            selectedCriteria.remove(criteria)
                        } else if selectedCriteria.count < 3 {
                            selectedCriteria.insert(criteria)
                        }
                    }
                }
            }
            .navigationBarTitle("Select Criteria")
        }
    }
}
    
    
    // PreferencesView definition
struct PreferencesView: View {
        @ObservedObject var viewModel = PlantViewModel()
        
        @State private var selectedState: String = "State"
        @State private var selectedPlantSize: String = "Plant Size"
        @State private var selectedFloweringColor: String = "Flowering Color"
        @State private var selectedPlantHeight: String = "Plant Height"
        @State private var selectedPlantType: String = "Plant Type"
        @State private var showResults = false
    @State private var preferredPlantType: PlantType? = nil
    @State private var preferredPlantSize: PlantSize? = nil
    @State private var preferredFloweringColor: FlowerColor? = nil
    @State private var preferredPlantHeight: String = PlantHeight.allCases.first?.rawValue ?? ""

    
    let floweringColors = ["Red", "Blue", "Yellow", "White"] /// Replace with your defaul


    
        
        var body: some View {
            VStack {
                Text("Select Your Preferences")
                    .font(.title)
                    .padding()
                
                Picker("State", selection: $selectedState) {
                    Text("State").tag("State")
                    ForEach(viewModel.states, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                // or any default valid size

                Picker("Plant Size", selection: $preferredPlantSize) {
                    ForEach(viewModel.plantSizes, id: \.self) { size in
                        Text(size).tag(size)
                    }
                }

                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Picker("Flowering Color", selection: $preferredFloweringColor) {
                    ForEach(floweringColors, id: \.self) { color in
                        Text(color).tag(color)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Picker("Plant Height", selection: $preferredPlantHeight) {
                    ForEach(PlantHeight.allCases, id: \.self) { height in
                        Text(height.rawValue).tag(height.rawValue)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Picker("Plant Type", selection: $preferredPlantType) {
                    ForEach(PlantType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Button("Recommended Plants") {
                    viewModel.filterPlants(state: selectedState, plantSize: selectedPlantSize, flowerColor: selectedFloweringColor, plantHeight: selectedPlantHeight, plantType: selectedPlantType)
                    showResults = true
                }
                .padding()
                
                NavigationLink(destination: ResultsView(viewModel: viewModel), isActive: $showResults) {
                    EmptyView()
                }


                
            }
        }
}
    
struct ChatbotView: View {
        @State private var userInput: String = ""
        @State private var messages: [String] = []
        
        var body: some View {
            VStack {
                ScrollView {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                            .padding()
                    }
                }
                
                HStack {
                    TextField("Ask a question...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Send") {
                        sendMessage()
                    }
                    .padding()
                }
            }
            .navigationBarTitle("FloraAI", displayMode: .inline)
        }
        
        func sendMessage() {
            // Append the user's message to the messages array
            messages.append("You: \(userInput)")
            
            // Call your chatbot API here and append its response to the messages array
            // This is a placeholder for actual chatbot API integration
            let botResponse = "Chatbot: I'm still learning. Please check back later!"
            messages.append(botResponse)
            
            userInput = "" // Clear the user input field
        }
}



    



