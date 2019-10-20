import XCTest
import EffectKit

final class EffectKit1Tests: XCTestCase {
    struct DoubleEffect: Effect {
        typealias F = ForIdentity
    }
    struct TripleEffect: Effect {
        typealias F = ForIdentity
    }
    struct DoubleHandler: HandlerFunction {
        typealias EF = ForIdentity
        
        func call<V>(value: V, next: @escaping (Kind1<ForIdentity, V>) -> Void) {
            next(Identity((value as! Int) * 2).asKind() as! Kind1<ForIdentity, V>)
        }
    }
    struct TripleHandler: HandlerFunction {
        typealias EF = ForIdentity
        
        func call<V>(value: V, next: @escaping (Kind1<ForIdentity, V>) -> Void) {
            next(Identity((value as! Int) * 3).asKind() as! Kind1<ForIdentity, V>)
        }
    }
    
    func test1() {
        let h1 = Handler<ForIdentity>()
        h1.onEffect(effect: DoubleEffect.self, DoubleHandler())
        h1.onEffect(effect: TripleEffect.self, TripleHandler())
        
        h1.run { (perform) in
            var x = perform.effect(DoubleEffect.self, 2)
            XCTAssertEqual(x.asIdentity().value, 4)
            x = perform.effect(TripleEffect.self, x.asIdentity().value)
            XCTAssertEqual(x.asIdentity().value, 12)
        }
    }
}
