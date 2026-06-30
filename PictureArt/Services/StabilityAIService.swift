import UIKit
import Foundation

enum AIServiceError: LocalizedError {
    case noAPIKey
    case networkError(Error)
    case apiError(String)
    case invalidResponse
    case imageEncodingFailed

    var errorDescription: String? {
        switch self {
        case .noAPIKey:               return "no_api_key"
        case .networkError(let e):   return e.localizedDescription
        case .apiError(let msg):     return msg
        case .invalidResponse:       return "Invalid server response"
        case .imageEncodingFailed:   return "Could not encode image"
        }
    }
}

struct StabilityAIService {
    private static let engineID = "stable-diffusion-xl-1024-v1-0"
    private static let baseURL = "https://api.stability.ai/v1/generation/\(engineID)/image-to-image"

    func transform(image: UIImage, style: DrawingStyle, apiKey: String) async throws -> UIImage {
        guard !apiKey.isEmpty else { throw AIServiceError.noAPIKey }

        let resized = image.resizedToFit(maxDimension: 1024).normalized()
        guard let imageData = resized.jpegData(compressionQuality: 0.8) else {
            throw AIServiceError.imageEncodingFailed
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        guard let url = URL(string: Self.baseURL) else { throw AIServiceError.apiError("Invalid API URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = buildBody(imageData: imageData, prompt: style.stabilityPrompt, boundary: boundary)
        request.timeoutInterval = 120

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AIServiceError.networkError(error)
        }

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let msg = (try? JSONDecoder().decode(APIErrorResponse.self, from: data))?.message ?? "HTTP \(http.statusCode)"
            throw AIServiceError.apiError(msg)
        }

        guard let json = try? JSONDecoder().decode(GenerationResponse.self, from: data),
              let artifact = json.artifacts.first(where: { $0.finishReason == "SUCCESS" }),
              let imgData = Data(base64Encoded: artifact.base64),
              let result = UIImage(data: imgData) else {
            throw AIServiceError.invalidResponse
        }

        return result
    }

    private func buildBody(imageData: Data, prompt: String, boundary: String) -> Data {
        var body = Data()
        let crlf = "\r\n"

        func field(_ name: String, _ value: String) {
            body.append("--\(boundary)\(crlf)".utf8Data)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\(crlf)\(crlf)".utf8Data)
            body.append(value.utf8Data)
            body.append(crlf.utf8Data)
        }

        // Image
        body.append("--\(boundary)\(crlf)".utf8Data)
        body.append("Content-Disposition: form-data; name=\"init_image\"; filename=\"image.jpg\"\(crlf)".utf8Data)
        body.append("Content-Type: image/jpeg\(crlf)\(crlf)".utf8Data)
        body.append(imageData)
        body.append(crlf.utf8Data)

        field("text_prompts[0][text]", prompt)
        field("text_prompts[0][weight]", "1")
        field("image_strength", "0.45")
        field("cfg_scale", "7")
        field("samples", "1")
        field("steps", "30")
        field("init_image_mode", "IMAGE_STRENGTH")

        body.append("--\(boundary)--\(crlf)".utf8Data)
        return body
    }

    // MARK: - Response Models

    private struct GenerationResponse: Decodable {
        let artifacts: [Artifact]
        struct Artifact: Decodable {
            let base64: String
            let finishReason: String
        }
    }

    private struct APIErrorResponse: Decodable {
        let message: String
    }
}

private extension String {
    var utf8Data: Data { Data(utf8) }
}

private extension Data {
    mutating func append(_ data: Data) { self += data }
}
