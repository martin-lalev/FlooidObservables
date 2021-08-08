//
//  MutableBindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 30.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

@propertyWrapper
@dynamicMemberLookup
public class MutableBindable<Value> {
    
    private var storedValue: Value
    private let dispatcher: Dispatcher = ClosureDispatcher()
    
    public init(with value: Value) {
        self.storedValue = value
    }
    public init(wrappedValue value: Value) {
        self.storedValue = value
    }

    public var wrappedValue: Value {
        get { self.value }
        set { self.update(to: newValue) }
    }
    
    public var projectedValue: MutableBindable<Value> { self }

    public func update(to value: Value) {
        self.storedValue = value
        dispatcher.post()
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
        return self.storedValue[keyPath: keyPath]
    }
    
    public func update(_ updater: (inout Value) -> Void) {
        var value = self.value
        updater(&value)
        self.update(to: value)
    }
}

extension MutableBindable: ObservableValue {

    public var value: Value {
        return self.storedValue
    }
    public func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol {
        dispatcher.add { [weak self] in
            guard let self = self else { return }
            observer(self.value)
        }
    }
}
