//
//  ObservableValue.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 27/06/2021.
//

public protocol ObservableValue {
    associatedtype Value
    var value: Value { get }
    func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol
}
