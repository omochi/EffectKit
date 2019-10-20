public protocol KindF1 {}

public struct Kind1<F: KindF1, A1> {
    public var _value: Any
    
    public init(_value: Any) {
        self._value = _value
    }
}

extension Kind1: Kind1Convertible {
    public init(kind: Kind1<F, A1>) {
        self = kind
    }
    
    public func asKind() -> Kind1<F, A1> {
        return self
    }
}
