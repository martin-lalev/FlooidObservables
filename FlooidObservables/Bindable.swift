//
//  Bindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 31.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

@propertyWrapper
@dynamicMemberLookup
public class Bindable<Value>: ObservableValue {
    
    var _value: () -> Value
    var _adder: (@escaping (Value) -> Void) -> NSObjectProtocol
    
    init<Base: ObservableValue>(_ base: Base) where Base.Value == Value {
        self._value = { base.value }
        self._adder = base.add(_:)
    }
    
    public var wrappedValue: Value { self.value }
    
    public var projectedValue: Bindable<Value> { self }
    
    public func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol {
        self._adder(observer)
    }
    
    public var value: Value {
        return self._value()
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Value,T>) -> Bindable<T> { self.map { $0[keyPath: keyPath] }.asAny() }
}

public extension ObservableValue {
    func asAny() -> Bindable<Value> { return Bindable(self) }
    func asAnyValue() -> BindableValue<Value> { return BindableValue(self) }
}

public typealias BindableValue<Value> = Bindable<Value>
public typealias BindableList<T> = Bindable<[T]>
