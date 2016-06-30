//
//  Errors.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/14/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

enum TextImportError: ErrorProtocol {
    case fileNotFound
    case badParse
    case unknownError
    case noInstrumentsFound
    case encodingError
}

enum TextExportError: ErrorProtocol {
    case propertyNotFound
    case couldNotExport
    case unknownError
}

enum InstrumentError: ErrorProtocol {
    case deviceTypeNotFound
    case propertyStringUnrecognized
    case ambiguousLocation
    case unrecognizedCoordinate
}

enum HungarianMatrixError: ErrorProtocol {
    case couldNotCreateMatrix
    case moreChannelsThanDimmers
    case twoferringExceedsWattage
    case noLocationSpecified
}

enum LengthFormatterError: ErrorProtocol {
    case unexpectedCharacter
    case stringToNumber
    case fractionalFormattingError
}
