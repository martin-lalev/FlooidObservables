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

public class BindableSink {
    var disposings: [AnyObject] = []
    public init() { }
    deinit { self.clean() }
    public func clean() { self.disposings.removeAll() }
}

class Subscriber<O: ObservableValue> {
    
    private var bindable: O
    private var observerToken: NSObjectProtocol?

    fileprivate init(to bindable: O, with action: @escaping (O.Value) -> Void) {
        self.bindable = bindable
        self.observerToken = bindable.add(action)
    }
    deinit {
        self.observerToken = nil
    }
}

public extension ObservableValue {
    
    func bind(into bindableSink: BindableSink, with action: @escaping (Value) -> Void) {
        bindableSink.disposings.append(Subscriber(to: self, with: action))
        action(self.value)
    }
}
