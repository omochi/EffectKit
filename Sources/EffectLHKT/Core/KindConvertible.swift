public protocol Kind1Convertible {
    associatedtype F: KindF1
    associatedtype A1
    
    init(kind: Kind1<F, A1>)
    
    func asKind() -> Kind1<F, A1>
}
