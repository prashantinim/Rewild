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
    var body: some Scene {
        WindowGroup {
            ContentView()
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
    @State private var username: String = "Username" // Replace with actual user data
    @State private var preferredPlantSize: String = "Select Size"
    @State private var preferredFloweringColor: String = "Select Color"
    @State private var preferredPlantType: String = "Select Type"
    @State private var preferredPlantHeight: String = "Select Height"
    
    @State private var plantsCultivatedCount: Int = 0
    @State private var newPlantName: String = ""
    @State private var newPlantCount: Int = 0
    
    @State private var isPreferencesSet: Bool = false
    @State private var plantsWishlist: [String] = []
    
    var plantSizes = ["Small", "Medium", "Large"]
    var floweringColors = ["Red", "Blue", "Yellow", "White"]
    var plantTypes = ["Succulent", "Fern", "Orchid"]
    var plantHeights = ["Short", "Medium", "Tall"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Welcome \(username)!")
                    .font(.title)
                    .padding()
                
                if !isPreferencesSet {
                    Text("Set Your Preferred Plant Characteristics")
                        .font(.headline)
                    
                    Picker("Plant Size", selection: $preferredPlantSize) {
                        ForEach(plantSizes, id: \.self) { Text($0) }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    
                    Picker("Flowering Color", selection: $preferredFloweringColor) {
                        ForEach(floweringColors, id: \.self) { Text($0) }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    
                    Picker("Plant Type", selection: $preferredPlantType) {
                        ForEach(plantTypes, id: \.self) { Text($0) }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    
                    Picker("Plant Height", selection: $preferredPlantHeight) {
                        ForEach(plantHeights, id: \.self) { Text($0) }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    
                    Button("Save Preferences") {
                        isPreferencesSet = true
                        // Logic to save preferences
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                    Text("Your Plant Preferences")
                        .font(.headline)
                    Text("Plant Size: \(preferredPlantSize)")
                    Text("Flowering Color: \(preferredFloweringColor)")
                    Text("Plant Type: \(preferredPlantType)")
                    Text("Plant Height: \(preferredPlantHeight)")
                }
                
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
                        // Reset for the next entry
                        newPlantName = ""
                        newPlantCount = 0
                        // Add logic to save/update plant cultivation data
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

struct UserLocationView: View {
    @State private var userState: String = UserState.allCases.first?.rawValue ?? ""
    @State private var userPostcode: String = UserPostcode.allCases.first?.rawValue ?? ""
    @ObservedObject var viewModel = PlantViewModel()
    
    @State private var preferredPlantSize: String = "Plant Size"
    @State private var preferredFloweringColor: String = "Flowering Color"
    @State private var preferredPlantType: String = "Plant Type"
    @State private var preferredPlantHeight: String = "Plant Height"
    
    @State private var showResults = false
    @State private var isLoading = false
    
    
    var body: some View {
        
        Form {
            Section(header: Text("Your Location")) {
                Picker("State", selection: $userState) {
                    ForEach(UserState.allCases, id: \.self) { state in
                        Text(state.rawValue).tag(state.rawValue)
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
                Picker("Plant Size", selection: $preferredPlantSize) {
                    ForEach(viewModel.plantSizes, id: \.self) { size in
                        Text(size).tag(size)
                    }
                }
                
                Picker("Flowering Color", selection: $preferredFloweringColor) {
                    ForEach(viewModel.floweringColors, id: \.self) { color in
                        Text(color).tag(color)
                    }
                }
                
                Picker("Plant Type", selection: $preferredPlantType) {
                    ForEach(viewModel.plantTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                
                Picker("Plant Height", selection: $preferredPlantHeight) {
                    ForEach(viewModel.plantHeights, id: \.self) { height in
                        Text(height).tag(height)
                    }
                }
            }
            
            Section(header: Text("Find Plants")) {
                Button("Find Plants") {
                    viewModel.fetchOpenAIPlantRecommendations(plantType: preferredPlantType, plantSize: preferredPlantSize, flowerColor: preferredFloweringColor, state: userState, postcode: userPostcode, plantHeight: preferredPlantHeight)
                }
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
                
            }
        }
    }
}
    
class PlantViewModel: ObservableObject {
        @Published var choices: [Choice] = []
        @Published var recommendedPlants: [Choice] = []
        @Published var requirements: String = ""
        @Published var careInfo: String = ""
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        
        var states: [String] {
            Array(Set(choices.map { $0.state.rawValue })).sorted()
        }
        var plantSizes: [String] {
            Array(Set(choices.map { $0.plantSize.rawValue })).sorted()
        }
        var floweringColors: [String] {
            Array(Set(choices.flatMap { $0.flowerColor.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }})).sorted()
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
        
        func filterPlants(state: String, plantSize: String, floweringColor: String, plantHeight: String, plantType: String) {
            recommendedPlants = choices.filter { choice in
                (state == "State" || choice.state.rawValue == state) &&
                (plantSize == "Plant Size" || choice.plantSize.rawValue == plantSize) &&
                (floweringColor == "Flowering Color" || choice.flowerColor.contains(floweringColor)) &&
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
        
        func fetchOpenAIPlantRecommendations(plantType: String, plantSize: String, flowerColor: String, state: String, postcode: String, plantHeight: String) {
            isLoading = true
            APICaller.shared.getPlantRecommendations(state: state, postcode: postcode, plantType: plantType, plantSize: plantSize, flowerColor: flowerColor, plantHeight: plantHeight) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let response):
                        self?.recommendedPlants = response
                        print("Fetched plants: \(response)")
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        print("Error fetching plants: \(error)")
                        
                        
                        
                    }
                    
                }
            }
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
        List(viewModel.recommendedPlants, id: \.id) { plant in
            VStack(alignment: .leading) {
                Text(plant.scientificName)
                // Add more details as needed
            }
        }
        .navigationBarTitle("Recommended Plants")
        .onAppear {
            if viewModel.recommendedPlants.isEmpty {
                Text("No plants found")
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
                
                Picker("Plant Size", selection: $selectedPlantSize) {
                    Text("Plant Size").tag("Plant Size")
                    ForEach(PlantSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size.rawValue)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Picker("Flowering Color", selection: $selectedFloweringColor) {
                    Text("Flowering Color").tag("Flowering Color")
                    ForEach(viewModel.floweringColors, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Picker("Plant Height", selection: $selectedPlantHeight) {
                    Text("Plant Height").tag("Plant Height")
                    ForEach(PlantHeight.allCases, id: \.self) {
                        Text($0.rawValue).tag($0.rawValue)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Picker("Plant Type", selection: $selectedPlantType) {
                    Text("Plant Type").tag("Plant Type")
                    ForEach(viewModel.plantTypes, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Button("Recommended Plants") {
                    viewModel.filterPlants(state: selectedState, plantSize: selectedPlantSize, floweringColor: selectedFloweringColor, plantHeight: selectedPlantHeight, plantType: selectedPlantType)
                    showResults = true
                }
                .padding()
                
                NavigationLink(destination: ResultsView(viewModel: viewModel), isActive: $showResults) { EmptyView() }
                
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
    



