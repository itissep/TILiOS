import Foundation

struct AcronymRequest {
  let resource: URL
  
  init(acronymID: UUID) {
    let resourceString = "http://localhost:8080/api/acronyms/\(acronymID)"
    guard let resourceURL = URL(string: resourceString) else {
      fatalError("Unable to createURL")
    }
    self.resource = resourceURL
  }
  
  func getUser(
    complition: @escaping (Result<User,ResourceRequestError>) -> Void) {
      let url = resource.appendingPathComponent("user")
      
      let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let jsonData = data else {
          complition(.failure(.noData))
          return
        }
        do {
          let user = try JSONDecoder().decode(User.self, from: jsonData)
          complition(.success(user))
          
        } catch {
          complition(.failure(.decodingError))
        }
        
      }
      dataTask.resume()
    }
  
  func getCategories(
    completion: @escaping (
      Result<[Category], ResourceRequestError>
    ) -> Void ) {
      let url = resource.appendingPathComponent("categories")
      let dataTask = URLSession.shared
        .dataTask(with: url) { data, _, _ in
          guard let jsonData = data else {
            completion(.failure(.noData))
            return
          }
          do {
            let categories = try JSONDecoder()
              .decode([Category].self, from: jsonData)
            completion(.success(categories))
          } catch {
            completion(.failure(.decodingError))
          }
        }
      dataTask.resume()
    }
  
  func update(with updateData: CreateAcronymData, completion: @escaping (Result<Acronym, ResourceRequestError>) -> Void) {
    do {
      var urlRequest = URLRequest(url: resource)
      urlRequest.httpMethod = "PUT"
      urlRequest.httpBody = try JSONEncoder().encode(updateData)
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
          completion(.failure(.noData))
          return
        }
        do {
          let acroynm = try JSONDecoder().decode(Acronym.self, from: jsonData)
          completion(.success(acroynm))
        } catch {
          completion(.failure(.decodingError))
        }
        
        
      }
      dataTask.resume()
    } catch {
      completion(.failure(.encodingError))
    }
  }
  
  func delete() {
    var urlRequest = URLRequest(url: resource)
    urlRequest.httpMethod = "DELETE"
    
    let dataTask = URLSession.shared.dataTask(with: urlRequest)
    dataTask.resume()
  }
  
  func add(category: Category, complition: @escaping (Result<Void, CategoryAddError>) -> Void) {
    guard let categoryID = category.id else {
      complition(.failure(.noID))
      return
    }
    let url = resource
      .appendingPathComponent("categories")
      .appendingPathComponent("\(categoryID)")
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    
    let dataTask = URLSession.shared.dataTask(with: urlRequest) { _, response, _ in
      guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 201
      else {
        complition(.failure(.invalidResponse))
        return
      }
      complition(.success(()))
    }
    dataTask.resume()
    
  }
  
}
