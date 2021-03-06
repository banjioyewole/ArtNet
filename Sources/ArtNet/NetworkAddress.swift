//
//  Address.swift
//  
//
//  Created by Alsey Coleman Miller on 2/21/20.
//

import Foundation

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin
#elseif os(Linux) || os(Android)
import Glibc
#endif

/// Network Address
public enum NetworkAddress: Equatable, Hashable {
    
    case ipv4(IPv4)
    case ipv6(IPv6)
}

extension NetworkAddress: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        case let .ipv4(address): return address.description
        case let .ipv6(address): return address.description
        }
    }
}

public protocol NetworkAddressProtocol: RawRepresentable {
    
    associatedtype SocketAddress
    
    init(address: SocketAddress)
    
    var address: SocketAddress { get }
    
    init?(rawValue: String)
    
    var rawValue: String { get }
}

extension NetworkAddressProtocol where Self: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}

extension NetworkAddressProtocol where Self: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let value = Self.init(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid \(Self.self) address \(rawValue)")
        }
        self = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public extension NetworkAddress {
    
    struct IPv4: NetworkAddressProtocol, Equatable, Codable, CustomStringConvertible {
        
        public let address: in_addr
        
        public init(address: in_addr) {
            self.address = address
        }
    }
}

public extension NetworkAddress.IPv4 {
    
    /// Zero address
    static var zero: NetworkAddress.IPv4 { return .init(address: in_addr(s_addr: 0x00)) }
}

extension NetworkAddress.IPv4: RawRepresentable {
    
    public init?(rawValue: String) {
        
        guard let address = SocketAddress(rawValue)
            else { return nil }
        
        self.address = address
    }
    
    public var rawValue: String {
        return address.presentation
    }
}

extension NetworkAddress.IPv4: Hashable {
    
    public var hashValue: Int {
        return unsafeBitCast(address, to: UInt32.self).hashValue
    }
}

extension NetworkAddress.IPv4: ArtNetCodable {
    
    public init?(artNet data: Data) {
        guard data.count == 4 else { return nil }
        self.init(address: .init(s_addr: .init(bytes: (data[0], data[1], data[2], data[3]))))
    }
    
    public var artNet: Data {
        return address.s_addr.binaryData
    }
    
    public static var artNetLength: Int { return 4 }
}

public extension NetworkAddress {
    
    struct IPv6: NetworkAddressProtocol, Equatable, Codable, CustomStringConvertible {
        
        public let address: in6_addr
        
        public init(address: in6_addr) {
            self.address = address
        }
    }
}

extension NetworkAddress.IPv6: RawRepresentable {
    
    public init?(rawValue: String) {
        
        guard let address = SocketAddress(rawValue)
            else { return nil }
        
        self.address = address
    }
    
    public var rawValue: String {
        return address.presentation
    }
}

extension NetworkAddress.IPv6: Hashable {
    
    public var hashValue: Int {
        let bit128Value = unsafeBitCast(address, to: uuid_t.self)
        return UUID(uuid: bit128Value).hashValue
    }
}

internal protocol InternetAddress {
    
    static var stringLength: Int { get }
    
    static var addressFamily: sa_family_t { get }
    
    init()
}

extension InternetAddress {
    
    init?(_ presentation: String) {
        
        var address = Self.init()
        
        /**
         inet_pton() returns 1 on success (network address was successfully converted). 0 is returned if src does not contain a character string representing a valid network address in the specified address family. If af does not contain a valid address family, -1 is returned and errno is set to EAFNOSUPPORT.
        */
        guard inet_pton(Int32(Self.addressFamily), presentation, &address) == 1
            else { return nil }
        
        self = address
    }
    
    var presentation: String {
        
        var output = Data(count: Int(Self.stringLength))
        var address = self
        guard let presentationBytes = output.withUnsafeMutableBytes({
            inet_ntop(Int32(Self.addressFamily),
                      &address,
                      $0,
                      socklen_t(Self.stringLength))
        }) else {
            fatalError("Invalid \(Self.self) address")
        }
        
        return String(cString: presentationBytes)
    }
}

extension in_addr: InternetAddress {
    
    static var stringLength: Int { return Int(INET_ADDRSTRLEN) }
    
    static var addressFamily: sa_family_t { return sa_family_t(AF_INET) }
}

extension in6_addr: InternetAddress {
    
    static var stringLength: Int { return Int(INET6_ADDRSTRLEN) }
    
    static var addressFamily: sa_family_t { return sa_family_t(AF_INET6) }
}
