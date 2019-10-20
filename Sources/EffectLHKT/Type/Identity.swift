public struct Identity<T> {
    public var value: T
    
    public init(_ value: T) {
        self.value = value
    }
}

extension Identity: Kind1Convertible {
    public typealias F = ForIdentity
    public typealias A1 = T
    
    public init(kind: Kind1<F, A1>) {
        self = kind._value as! Identity<T>
    }
    
    public func asKind() -> Kind1<ForIdentity, T> {
        Kind1(_value: self as Any)
    }
}

public enum ForIdentity: KindF1 {}

extension Kind1 where F == ForIdentity {
    public func asIdentity() -> Identity<A1> {
        Identity(kind: self)
    }
}
