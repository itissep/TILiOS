import Foundation

struct ResourceRequest<ResourceType> where ResourceType: Codable {
  let baseURL = "http://127.0.0.1:8080/api/"
  let resourceURL: URL
  
  init(resourcePath: String) {
    guard let resourceURL = URL(string: baseURL) else {
      fatalError("Failed to conver baseURL to a URL")
    }
    self.resourceURL = resourceURL.appendingPathComponent(resourcePath)
  }
  
  func getAll(completion: @escaping (Result<[ResourceType], ResourceRequestError>) -> Void) {
    let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, _ in
      guard let jsonData = data else {
        completion(.failure(.noData))
        return
      }
      do {
        let resources = try JSONDecoder().decode([ResourceType].self, from: jsonData)
        completion(.success(resources))
      } catch {
        completion(.failure(.decodingError))
      }
    }
    dataTask.resume()
  }
  
  func save<CreateType>(_ saveData: CreateType, complition: @escaping (Result<ResourceType, ResourceRequestError>) -> Void) where CreateType: Codable {
    do {
      var urlRequest = URLRequest(url: resourceURL)
      urlRequest.httpMethod = "POST"
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = try JSONEncoder().encode(saveData)
      let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
          complition(.failure(.noData))
          return
        }
        
        do {
          let resource = try JSONDecoder().decode(ResourceType.self, from: jsonData)
          complition(.success(resource))
        } catch {
          complition(.failure(.decodingError))
        }
      }
      
      dataTask.resume()
      
    } catch {
      complition(.failure(.encodingError))
    }
    
    
  }
}
