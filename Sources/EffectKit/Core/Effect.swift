import EffectLHKT

@_exported import EffectLHKT

public protocol Effect {
    associatedtype F: KindF1
}
