//
//  ObservableValue.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 27/06/2021.
//

import Foundation

@dynamicMemberLookup
public protocol ObservableValue<Value> {
    associatedtype Value
    var value: Value { get }
    func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol
}

extension ObservableValue {
    public subscript<T>(dynamicMember keyPath: KeyPath<Value,T>) -> some ObservableValue<T> { self.map { $0[keyPath: keyPath] } }
}
