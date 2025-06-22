import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let nik: String?
    let nama: String
    let email: String?
    let role: String
    let alamat: String?
    let noHp: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, nik, nama, email, role, alamat
        case noHp = "no_hp"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Main initializer with all parameters
    init(id: Int, 
         nik: String? = nil, 
         nama: String, 
         email: String? = nil,
         role: String, 
         alamat: String? = nil, 
         noHp: String? = nil, 
         createdAt: Date? = nil, 
         updatedAt: Date? = nil) {
        self.id = id
        self.nik = nik
        self.nama = nama
        self.email = email
        self.role = role
        self.alamat = alamat
        self.noHp = noHp
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Decoder initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required fields
        id = try container.decode(Int.self, forKey: .id)
        nama = try container.decode(String.self, forKey: .nama)
        role = try container.decode(String.self, forKey: .role)
        
        // Decode optional fields
        nik = try container.decodeIfPresent(String.self, forKey: .nik)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        alamat = try container.decodeIfPresent(String.self, forKey: .alamat)
        noHp = try container.decodeIfPresent(String.self, forKey: .noHp)
        
        // Handle date decoding with custom date formatter
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Decode dates
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString)
        } else {
            createdAt = nil
        }
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = dateFormatter.date(from: updatedAtString)
        } else {
            updatedAt = nil
        }
    }
}

struct LoginResponse: Codable {
    let message: String
    let user: User
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case message, user, token
    }
}

struct UserResponse: Codable {
    let message: String
    let data: User
    
    enum CodingKeys: String, CodingKey {
        case message, data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        data = try container.decode(User.self, forKey: .data)
    }
}

struct UsersResponse: Codable {
    let message: String
    let data: [User]
    
    enum CodingKeys: String, CodingKey {
        case message, data
    }
}

struct ProfileUpdateResponse: Codable {
    let message: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case message, user
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        user = try container.decode(User.self, forKey: .user)
    }
}
