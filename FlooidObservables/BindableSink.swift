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
    
    fileprivate init(to bindable: O, with action: @escaping (O.Value) -> Void) {
        self.bindable = bindable
        self.storedAction = action
        bindable.add(self, selector: #selector(self.action))
        self.action()
    }
    deinit {
        self.bindable.remove(self)
    }
    
    @discardableResult
    public func dispose(into bindableSink: BindableSink) -> Subscriber {
        bindableSink.disposings.append(self)
        return self
    }
    
    @objc private func action() {
        self.storedAction(self.bindable.value)
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
    
}
