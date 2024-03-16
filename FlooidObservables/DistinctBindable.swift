//
//  DistinctBindable.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 04/02/2023.
//

import Foundation

class DistinctBindable<Value> {
    private let wrapperValue: MutableBindable<Value>
    private let baseResults: any ObservableValue<Value>
    private var observerToken: NSObjectProtocol?

    init(for baseResults1: some ObservableValue<Value>, _ filter: @escaping (_ oldValue: Value, _ newValue: Value) -> Bool) {
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
    
    var value: Value {
        return self.wrapperValue.value
    }
    
    func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol {
        self.wrapperValue.add(observer)
    }
    
}

public extension ObservableValue {

    func distinct(_ filter: @escaping (_ oldValue: Value, _ newValue: Value) -> Bool) -> some ObservableValue<Value> {
        return DistinctBindable(for: self, filter)
    }
    
    func distinct<O: AnyObject>(_ object: O, _ filter: @escaping (O, _ oldValue: Value, _ newValue: Value) -> Bool) -> some ObservableValue<Value> {
        return DistinctBindable(for: self) { [unowned object] in filter(object, $0, $1) }
    }
    
}

public extension ObservableValue where Value: Equatable {
    func distinctEquatable() -> some ObservableValue<Value> {
        return self.distinct { $0 != $1 }
    }
}

public extension ObservableValue where Value: Identifiable {
    func distinctIdentifiable() -> some ObservableValue<Value> {
        return self.distinct { $0.id != $1.id }
    }
}
