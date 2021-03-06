//
// Parakeet.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


open class Parakeet: JSONEncodable {
    public var color: String?
    public var soundRepeater: Bool?
    public var soundRepeaterNum: NSNumber? {
        get {
            return soundRepeater.map({ return NSNumber(value: $0) })
        }
    }

    public init() {}

    // MARK: JSONEncodable
    open func encodeToJSON() -> Any {
        var nillableDictionary = [String:Any?]()
        nillableDictionary["color"] = self.color
        nillableDictionary["soundRepeater"] = self.soundRepeater

        let dictionary: [String:Any] = APIHelper.rejectNil(nillableDictionary) ?? [:]
        return dictionary
    }
}
