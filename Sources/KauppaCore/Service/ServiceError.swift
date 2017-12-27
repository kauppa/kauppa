///
public protocol ServiceError: Error, RawRepresentable
    where RawValue == UInt16
{
    //
}

public struct MappableServiceError: Mappable {
    ///
    public let code: UInt16
}
