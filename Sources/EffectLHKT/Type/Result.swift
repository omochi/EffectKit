extension Result: Kind1Convertible where Failure == Swift.Error {
    public typealias F = ForResult
    public typealias A1 = Success
    
    public init(kind: Kind1<ForResult, Success>) {
        self = kind._value as! Result<Success, Error>
    }
    
    public func asKind() -> Kind1<ForResult, Success> {
        Kind1(_value: self as Any)
    }
}

public enum ForResult: KindF1 {}
