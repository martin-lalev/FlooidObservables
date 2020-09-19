//
//  Bindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 31.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

public protocol ObservableValue {
    associatedtype Value
    var value: Value { get }
    func add(_ observer: Any, selector: Selector)
    func remove(_ observer: Any)
}

@dynamicMemberLookup
public class Bindable<Value>: ObservableValue {
    
    var _value: () -> Value
    var _add: (Any, Selector) -> Void
    var _remove: (Any) -> Void
    
    init<Base: ObservableValue>(_ base: Base) where Base.Value == Value {
        self._value = { base.value }
        self._add = base.add
        self._remove = base.remove
    }
    
    public func add(_ target: Any, selector: Selector) {
        self._add(target, selector)
    }
    public func remove(_ target: Any) {
        self._remove(target)
    }
    
    public var value: Value {
        return self._value()
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Value,T>) -> Bindable<T> { self.map { $0[keyPath: keyPath] }.asAny() }
}

public extension ObservableValue {
    func asAny() -> Bindable<Value> { return Bindable(self) }
}

public typealias BindableList<T> = Bindable<[T]>
