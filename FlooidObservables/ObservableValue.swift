//
//  ObservableValue.swift
//  FlooidObservables
//
//  Created by Martin Lalev on 27/06/2021.
//

import Combine

public protocol ObservableValue {
    associatedtype Value
    var value: Value { get }
    func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol
}

public class BindableSink: NSObject {
    var disposings: [AnyCancellable] = []
    deinit { self.clean() }
    public func clean() { self.disposings.removeAll() }
}

public extension ObservableValue {
    
    func bind(into bindableSink: BindableSink, with action: @escaping (Value) -> Void) {
        bindableSink.disposings.append(self.asAny().sink(receiveValue: { _ in action(self.value) }))
        action(self.value)
    }
}
