import SwiftUI
import SwiftData

@main
struct IPTVApp: App {
    let container: ModelContainer
    
    @AppStorage("savedBaseURL") private var savedBaseURL = ""
    @AppStorage("savedUsername") private var savedUsername = ""
    
    init() {
        do {
            let schema = Schema([
                Channel.self,
                Movie.self,
                Series.self,
                Episode.self,
                Category.self,
                Actor.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to initialize SwiftData Container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !savedUsername.isEmpty,
                   let securePassword = KeychainManager.shared.getPassword(for: savedUsername) {
                    
                    MainCoordinatorView(
                        baseURL: savedBaseURL,
                        username: savedUsername,
                        password: securePassword,
                        container: container
                    )
                    
                } else {
                    LoginView { host, username, password in
                        KeychainManager.shared.savePassword(password, for: username)
                        savedBaseURL = host
                        savedUsername = username
                }
            }
        }
        .modelContainer(container)
    }
}


struct MainCoordinatorView: View {
    @StateObject private var repository: MediaRepository
    
    init(baseURL: String, username: String, password: String, container: ModelContainer) {
        let xtream = XtreamService(baseURL: baseURL, username: username, password: password)
        let tmdb = TMDBService(apiKey: "YOUR_TMDB_API_KEY")
        
        let repo = MediaRepository(
            xtreamService: xtream,
            tmdbService: tmdb,
            modelContainer: container
        )
        _repository = StateObject(wrappedValue: repo)
    }
    
    var body: some View {
        MainDashboardView()
            .environmentObject(repository)
            .task {
                await repository.syncProviderCategories()
                
                await repository.performFullSync()
            }
    }
}