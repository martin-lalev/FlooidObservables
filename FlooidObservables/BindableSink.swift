//
//  BindableSink.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 16.11.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

public class BindableSink {
    var disposings: [AnyObject] = []
    public init() { }
    deinit { self.clean() }
    public func clean() { self.disposings.removeAll() }
}

public class Subscriber<O: ObservableValue> {
    
    private var bindable: O
    private let storedAction: (O.Value) -> Void
    private var observerToken: NSObjectProtocol?

    fileprivate init(to bindable: O, with action: @escaping (O.Value) -> Void) {
        self.bindable = bindable
        self.storedAction = action
        self.observerToken = bindable.add { [weak self] value in
            guard let self = self else { return }
            self.action(value)
        }
        self.action(bindable.value)
    }
    deinit {
        self.observerToken = nil
    }
    
    @discardableResult
    public func dispose(into bindableSink: BindableSink) -> Subscriber {
        bindableSink.disposings.append(self)
        return self
    }
    
    private func action(_ value: O.Value) {
        self.storedAction(value)
    }
}

public extension ObservableValue {
    
    func subscribe(with action: @escaping (Value) -> Void) -> Subscriber<Self> {
        return Subscriber(to: self, with: action)
    }
    @discardableResult
    func bind(into bindableSink: BindableSink, with action: @escaping (Value) -> Void) -> Subscriber<Self> {
        self.subscribe(with: action).dispose(into: bindableSink)
    }
    
    func assign<O: AnyObject>(to keyPath: ReferenceWritableKeyPath<O, Value>, on object: O) -> Subscriber<Self> {
        self.subscribe { value in
            object[keyPath: keyPath] = value
        }
    }
    @discardableResult
    func assign<O: AnyObject>(via bindableSink: BindableSink, to keyPath: ReferenceWritableKeyPath<O, Value>, on object: O) -> Subscriber<Self> {
        self.bind(into: bindableSink) { value in
            object[keyPath: keyPath] = value
        }
    }

}
