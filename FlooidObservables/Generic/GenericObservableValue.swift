//
//  GenericObservableValue.swift
//  
//
//  Created by Martin Lalev on 31/05/2025.
//

import Foundation

public final class GenericObservableValue<Value>: ObservableValue, Sendable {
    private nonisolated(unsafe) let proxy: MutableBindable<Value>
    private nonisolated(unsafe) var observer: NSObjectProtocol?
    
    public init(
        initialValue: Value,
        subscribe: (_ observation: @Sendable @escaping (Value) -> Void) -> NSObjectProtocol
    ) {
        self.proxy = .init(with: initialValue)
        self.observer = subscribe { [weak self] in
            self?.proxy.update(to: $0)
        }
    }
    deinit {
        self.observer = nil
    }

    public func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol {
        self.proxy.add(observer)
    }
    public var value: Value {
        self.proxy.value
    }
}
