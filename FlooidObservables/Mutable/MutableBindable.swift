//
//  MutableBindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 30.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

@propertyWrapper
public class MutableBindable<Value> {
    
    private var storedValue: Value
    private let publisher = ValuePublisher<Value>()
    
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
        publisher.post(value)
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
        publisher.add { value in
            observer(value)
        }
    }
}
