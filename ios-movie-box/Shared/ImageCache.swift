import SwiftUI

actor ImageCache {
    static let shared = ImageCache()
    
    private var cache: [URL: Image] = [:]
    private var loadingTasks: [URL: Task<Image?, Error>] = [:]
    
    func image(for url: URL) -> Image? {
        cache[url]
    }
    
    func load(_ url: URL) async throws -> Image? {
        // Get image from cache if exits
        if let cached = cache[url] {
            return cached
        }
        
        // Check if there's already a loading task
        if let existingTask = loadingTasks[url] {
            return try await existingTask.value
        }
        
        // Create new loading task
        let task = Task<Image?, Error> {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let uiImage = UIImage(data: data) else {
                return nil
            }
            
            let image = Image(uiImage: uiImage)
            cache[url] = image
            loadingTasks[url] = nil
            return image
        }
        
        loadingTasks[url] = task
        return try await task.value
    }
    
    func clearCache() {
        cache.removeAll()
        loadingTasks.values.forEach { $0.cancel() }
        loadingTasks.removeAll()
    }
}
