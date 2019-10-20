public protocol HandlerFunction {
    associatedtype EF: KindF1
    func call<V>(value: V, next: @escaping (Kind1<EF, V>) -> Void)
}

public struct AnyHandlerFunction<EF: KindF1> {
    public class BoxBase {
        public func call<V>(_ value: V, next: @escaping (Kind1<EF, V>) -> Void) {
            fatalError()
        }
    }
    
    public final class Box<X: HandlerFunction>: BoxBase where X.EF == EF {
        private let x: X
        public init(_ x: X) { self.x = x }
        public override func call<V>(_ value: V, next: @escaping (Kind1<EF, V>) -> Void) {
            x.call(value: value, next: next)
        }
    }
    
    private let box: BoxBase
    
    public init<X: HandlerFunction>(_ x: X) where X.EF == EF {
        box = Box(x)
    }
    
    public func call<V>(_ value: V, next: @escaping (Kind1<EF, V>) -> Void) {
        box.call(value, next: next)
    }
}
