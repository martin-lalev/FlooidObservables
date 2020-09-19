//
//  MutableBindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 30.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public class MutableBindable<Value> {
    
    private var storedValue: Value
    private let name: Notification.Name = .init("mutable_bindable")
    
    public init(with value: Value) {
        self.storedValue = value
    }
    
    public func update(to value: Value) {
        self.storedValue = value
        NotificationCenter.default.post(name: self.name, object: self, userInfo: nil)
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

    public func add(_ target: Any, selector: Selector) {
        NotificationCenter.default.addObserver(target, selector: selector, name: self.name, object: self)
    }
    public func remove(_ target: Any) {
        NotificationCenter.default.removeObserver(target, name: self.name, object: self)
    }
    public var value: Value {
        return self.storedValue
    }
}
