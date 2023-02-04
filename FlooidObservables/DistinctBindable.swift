//
//  DistinctBindable.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 04/02/2023.
//

import Foundation

public class DistinctBindable<Value> {
    private let wrapperValue: MutableBindable<Value>
    private let baseResults: Bindable<Value>
    private var observerToken: NSObjectProtocol?

    public init<O: ObservableValue>(for baseResults1: O, _ filter: @escaping (_ oldValue: Value, _ newValue: Value) -> Bool) where O.Value == Value {
        self.wrapperValue = .init(with: baseResults1.value)
        self.baseResults = baseResults1.asAny()

        self.observerToken = baseResults1.add { [weak self] value in
            guard let self = self else { return }
            guard filter(self.wrapperValue.value, value) else { return }
            self.wrapperValue.update(to: value)
        }
    }
    deinit {
        self.observerToken = nil
    }
}

extension DistinctBindable: ObservableValue {
    
    public var value: Value {
        return self.wrapperValue.value
    }
    
    public func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol {
        self.wrapperValue.add(observer)
    }
    
}

extension ObservableValue {

    public func distinct(_ filter: @escaping (_ oldValue: Value, _ newValue: Value) -> Bool) -> DistinctBindable<Value> {
        return DistinctBindable(for: self, filter)
    }
    
    public func distinct<O: AnyObject>(_ object: O, _ filter: @escaping (O, _ oldValue: Value, _ newValue: Value) -> Bool) -> DistinctBindable<Value> {
        return DistinctBindable(for: self) { [unowned object] in filter(object, $0, $1) }
    }
    
}

extension ObservableValue where Value: Equatable {
    public func distinctEquatable() -> DistinctBindable<Value> {
        return self.distinct { $0 != $1 }
    }
}

extension ObservableValue where Value: Identifiable {
    public func distinctIdentifiable() -> DistinctBindable<Value> {
        return self.distinct { $0.id != $1.id }
    }
}
