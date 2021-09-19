import Foundation

class JuggledData: ObservableObject {
    private static var documentsFolder: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: false)
        } catch {
            fatalError("Can't find documents directory.")
        }
    }

    private static var fileURL: URL {
        return documentsFolder.appendingPathComponent("juggled.data")
    }
    
    @Published var routines: [Routine] = []

    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let data = try? Data(contentsOf: Self.fileURL) else {
                #if DEBUG
                DispatchQueue.main.async {
                    self?.routines = []
                }
                #endif
                return
            }

            guard let routines = try? JSONDecoder().decode([Routine].self, from: data) else {
                fatalError("Can't decode saved routine data.")
            }
            
            DispatchQueue.main.async {
                self?.routines = routines
            }
        }
    }
    
    func save() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let routines = self?.routines else { fatalError("Self out of scope") }
            guard let data = try? JSONEncoder().encode(routines) else { fatalError("Error encoding data") }
            
            do {
                let outfile = Self.fileURL
                try data.write(to: outfile)
            } catch {
                fatalError("Can't write to file")
            }
        }
    }
}
