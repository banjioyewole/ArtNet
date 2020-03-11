//
//  File.swift
//  
//
//  Created by Jorge Loc Rubio on 3/10/20.
//

import Foundation

public struct ArtTodData: ArtNetPacket, Equatable, Hashable, Codable {
    
    /// ArtNet packet code.
    public static var opCode: OpCode { return .todData }
    
    /// Art-Net formatting
    public static let formatting = ArtNetFormatting()
    
    /// Art-Net protocol revision.
    public let protocolVersion: ProtocolVersion
    
    /// Art-Net rdm version
    public let rdmVersion: RdmVersion
    
    /// Physical Port. Range 1-4
    public let port: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare1: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare2: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare3: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare4: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare5: UInt8
    
    /// Transmit as zero, receivers don’t test.
    internal let spare6: UInt8
    
    /// The BindIndex definesthe bound node which originated this packed.
    
    /// In combination with Port and Source IP address, it uniquely identifies the sender.
    
    /// This must match the BindIndex field in ArtPollReply.
    
    /// This number represents the order of bound devices.
    
    /// A lower number means closer to root device. A value of 1 means root device.
    public let bindingIndex: UInt8
    
    /// The top 7 bits of the 15 bit Port-Address of Nodes that must respond to this packet.
    public var net: PortAddress.Net
    
    /// Command
    public var command: Command
    
    /// The low 8 bits of the Port-Address of the Output Gateway DMX Port that generated this packet. the high nibble is the Sub-Net switch. The low nibble corresponds to the Universe.
    public var address: Address
    
    /// The total number of RDM devices discovered by this Universe.
    public var uidTotal: UidTotal
    
    /// The index number of this packet. When UidTotal exceeds 200, multiple ArtTodData packets are used.
    
    /// BlockCount is set to zero for the first packet, and incremented for each subsequent packet containing blocks of TOD information
    public var blockCount: UInt8
    
    /// The number of UIDs encoded in this packet. This is the index of the following array.
    public var uidCount: UInt8
    
    /// Array of RDM UID.
    public var tod: [UInt]
}

// MARK: - Command

public extension ArtTodData {
    
    /// Command
    enum Command: UInt8, Codable {
        
        /// The packet contains the entire TOD or is the first packet in a sequence of packets that contains the entire TOD.
        case todFull = 0x00
        
        /// The TOD is not available or discovert is incomplete
        case todNak = 0xFF
    }
}

// MARK: - UidTotal
struct UidTotal: RawRepresentable, Equatable, Hashable, Codable {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

// MARK: - CustomStringConvertible

extension UidTotal: CustomStringConvertible {
    
    public var description: String {
        return "0x" + rawValue.toHexadecimal()
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension UidTotal: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.rawValue = value
    }
}
