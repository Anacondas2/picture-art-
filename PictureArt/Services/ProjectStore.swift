import Foundation
import UIKit

final class ProjectStore: ObservableObject {
    static let shared = ProjectStore()

    @Published var projects: [ArtProject] = []

    private let fm = FileManager.default
    private let defaults = UserDefaults.standard

    var apiKey: String {
        get { defaults.string(forKey: "stabilityAPIKey") ?? "" }
        set { defaults.set(newValue, forKey: "stabilityAPIKey") }
    }

    private init() { load() }

    private func documentsURL() -> URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask).first ?? fm.temporaryDirectory
    }

    func projectURL(_ project: ArtProject) -> URL {
        documentsURL().appendingPathComponent(project.id.uuidString)
    }

    private func projectURL(id: UUID) -> URL {
        documentsURL().appendingPathComponent(id.uuidString)
    }

    // MARK: - Load/Save Project

    func load() {
        let ids = defaults.stringArray(forKey: "projectIds") ?? []
        projects = ids.compactMap { idString -> ArtProject? in
            guard let id = UUID(uuidString: idString) else { return nil }
            let url = projectURL(id: id).appendingPathComponent("project.json")
            guard let data = try? Data(contentsOf: url),
                  let project = try? JSONDecoder().decode(ArtProject.self, from: data) else { return nil }
            return project
        }.sorted { $0.createdAt > $1.createdAt }
    }

    func save(_ project: ArtProject) {
        let dir = projectURL(project)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("project.json")
        if let data = try? JSONEncoder().encode(project) {
            try? data.write(to: url, options: .atomic)
        }

        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            projects[idx] = project
        } else {
            projects.insert(project, at: 0)
        }

        defaults.set(projects.map { $0.id.uuidString }, forKey: "projectIds")
    }

    func delete(_ project: ArtProject) {
        try? fm.removeItem(at: projectURL(project))
        projects.removeAll { $0.id == project.id }
        defaults.set(projects.map { $0.id.uuidString }, forKey: "projectIds")
    }

    // MARK: - Images

    func saveOriginalImage(_ image: UIImage, for project: ArtProject) {
        let url = projectURL(project).appendingPathComponent("original.jpg")
        try? image.jpegDataMedium?.write(to: url, options: .atomic)
    }

    func saveStyledImage(_ image: UIImage, for project: ArtProject) {
        let url = projectURL(project).appendingPathComponent("styled.jpg")
        try? image.jpegDataMedium?.write(to: url, options: .atomic)
    }

    func saveTile(_ image: UIImage, row: Int, col: Int, for project: ArtProject) {
        let tilesDir = projectURL(project).appendingPathComponent("tiles")
        try? fm.createDirectory(at: tilesDir, withIntermediateDirectories: true)
        let url = tilesDir.appendingPathComponent("\(row)_\(col).jpg")
        try? image.jpegData(compressionQuality: 0.85)?.write(to: url, options: .atomic)
    }

    func loadOriginalImage(for project: ArtProject) -> UIImage? {
        UIImage(contentsOfFile: projectURL(project).appendingPathComponent("original.jpg").path)
    }

    func loadStyledImage(for project: ArtProject) -> UIImage? {
        UIImage(contentsOfFile: projectURL(project).appendingPathComponent("styled.jpg").path)
    }

    func loadDisplayImage(for project: ArtProject) -> UIImage? {
        loadStyledImage(for: project) ?? loadOriginalImage(for: project)
    }

    func loadTile(row: Int, col: Int, for project: ArtProject) -> UIImage? {
        UIImage(contentsOfFile: projectURL(project).appendingPathComponent("tiles/\(row)_\(col).jpg").path)
    }
}
