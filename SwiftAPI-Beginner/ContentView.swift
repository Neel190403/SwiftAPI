//
//  ContentView.swift
//  SwiftAPI-Beginner
//
//  Created by Neel Pandya on 13/02/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user:  GitHubUser?
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")){ image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.gray)
            }
            .frame(width: 150, height: 150)
            
            Text(user?.login ?? "User Placeholder")
                .bold()
                .font(.title2)
            
            
            Text(user?.bio ?? "Bio Placeholder")
            
            
            Spacer()
        }
        .padding()
        .task {
            do{
                user = try await getUser()
            } catch GHError.invalidURL{
                print("Invalid URL")
            } catch GHError.invalidData{
                print("Invalid data")
            } catch GHError.invalidResponse{
                print("Invalid Response")
            } catch {
                print("Unexpected error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endPoint = "https://api.github.com/users/twostraws"
        guard let url = URL(string: endPoint) else{
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
    
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch{
            throw GHError.invalidData
        }
}
}
    


#Preview {
    ContentView()
}

struct GitHubUser: Codable{
    let login       : String
    let avatarUrl   : String
    let bio         : String
}

enum GHError: Error{
    case invalidURL
    case invalidResponse
    case invalidData
}
