public enum GenericError: UInt16, ServiceError {
    case clientHTTPData     = 1

    case jsonParse          = 11
    case jsonErrorParse     = 12
    case jsonSerialization  = 13

    case unknownError       = 999
}
