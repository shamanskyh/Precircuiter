//
//  Errors.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 5/14/15.
//  Copyright © 2015 Harry Shamansky. All rights reserved.
//

enum TextImportError: ErrorType {
    case FileNotFound
    case BadParse
    case UnknownError
    case NoInstrumentsFound
    case EncodingError
}

enum TextExportError: ErrorType {
    case PropertyNotFound
    case CouldNotExport
    case UnknownError
}

enum InstrumentError: ErrorType {
    case DeviceTypeNotFound
    case PropertyStringUnrecognized
    case AmbiguousLocation
    case UnrecognizedCoordinate
}

enum HungarianMatrixError: ErrorType {
    case CouldNotCreateMatrix
    case MoreChannelsThanDimmers
    case TwoferringExceedsWattage
    case NoLocationSpecified
}

enum LengthFormatterError: ErrorType {
    case UnexpectedCharacter
    case StringToNumber
    case FractionalFormattingError
}