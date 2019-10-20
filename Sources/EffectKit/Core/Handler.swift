import Dispatch
import FiberKit

public final class Handler<F: KindF1> {
    public struct Perform {
        public weak var owner: Handler<F>?
        
        public init(owner: Handler<F>) {
            self.owner = owner
        }
        
        public func value<V>(_ value: V) -> Kind1<F, V> {
            owner!.perform(value: value)
        }
        
        public func effect<E: Effect, V>(_ effect: E.Type, _ value: V) -> Kind1<F, V> where E.F == F {
            owner!.perform(effect: effect, value: value)
        }
    }
    
    private enum FiberResult {
        case performEffect
        case exit
    }
    
    private var valueFn: AnyHandlerFunction<F>?
    private var effectFns: [ObjectIdentifier: AnyHandlerFunction<F>] = [:]
    
    private var fiber: Fiber<Void, FiberResult>?
    private var perform: Perform!
    private var yield: ((FiberResult) -> Void)?
    private var invokeHandler: (() -> Void)?
    
    public init() {}
    
    public func onValue<H: HandlerFunction>(
        _ fn: H) where H.EF == F
    {
        valueFn = AnyHandlerFunction(fn)
    }
    
    public func onEffect<E: Effect, H: HandlerFunction>(
        effect: E.Type,
        _ fn: H) where E.F == F, H.EF == F
    {
        effectFns[ObjectIdentifier(effect)] = AnyHandlerFunction(fn)
    }
    
    public func run(_ f: @escaping (_ perform: Perform) -> Void) {
        precondition(self.fiber == nil)
    
        let perform = Perform(owner: self)
        
        let fiber = Fiber<Void, FiberResult> { [weak self] (yield, _) -> FiberResult in
            guard let self = self else { preconditionFailure() }
            self.yield = yield
            f(perform)
            return .exit
        }
        self.fiber = fiber
        resumeFiber()
    }
    
    private func resumeFiber() {
        let fiber = self.fiber!
        Fibers.preconditionNotOnFiber(fiber)
        
        let fiberResult = fiber.resume(())
        
        switch fiberResult {
        case .exit: return
        case .performEffect:
            invokeHandler!()
        }
    }
    
    private func perform<V>(value: V) -> Kind1<F, V> {
        Fibers.preconditionOnFiber(fiber!)
        
        let fn = valueFn!
        return _perform(value: value, fn: fn)
    }
    
    private func perform<E: Effect, V>(effect: E.Type, value: V) -> Kind1<F, V>
        where E.F == F
    {
        Fibers.preconditionOnFiber(fiber!)
        
        let fn = effectFns[ObjectIdentifier(effect)]!
        return _perform(value: value, fn: fn)
    }
    
    private func _perform<V>(value: V, fn: AnyHandlerFunction<F>) -> Kind1<F, V> {
        Fibers.preconditionOnFiber(fiber!)
        
        var effectResult: Kind1<F, V>?

        invokeHandler = { [weak self] in
            let next = { [weak self] (result: Kind1<F, V>) -> Void in
                DispatchQueue.global().async { [weak self] in
                    guard let self = self else { preconditionFailure() }
                    
                    effectResult = result
                    
                    self.resumeFiber()
                }
            }
            
            fn.call(value, next: next)
        }
                
        // pause
        let yd = yield!
        yd(.performEffect)
        
        return effectResult!
    }
}
