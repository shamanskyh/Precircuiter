//
//  Errors.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/14/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

enum TextImportError: Error {
    case fileNotFound
    case badParse
    case unknownError
    case noInstrumentsFound
    case encodingError
}

enum TextExportError: Error {
    case propertyNotFound
    case couldNotExport
    case unknownError
}

enum InstrumentError: Error {
    case deviceTypeNotFound
    case propertyStringUnrecognized
    case ambiguousLocation
    case unrecognizedCoordinate
}

enum HungarianMatrixError: Error {
    case couldNotCreateMatrix
    case moreChannelsThanDimmers
    case twoferringExceedsWattage
    case noLocationSpecified
}

enum LengthFormatterError: Error {
    case unexpectedCharacter
    case stringToNumber
    case fractionalFormattingError
}
