//
//  BindableProxy.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 22.04.20.
//  Copyright © 2020 Martin Lalev. All rights reserved.
//

import Foundation

public class BindableProxy<Value> {

    private let wrappedValue: MutableBindable<Value>
    private var actual: Bindable<Value>?

    public init(with initialValue: Value) {
        self.wrappedValue = MutableBindable(with: initialValue)
    }
    deinit {
        self.actual?.remove(self)
        self.actual = nil
    }

    public func attach<O: ObservableValue>(to observable: O?) where O.Value == Value {
        self.actual?.remove(self)
        self.actual = nil
        self.actual = observable?.asAny()
        self.actual?.add(self, selector: #selector(updated))
        updated()
    }
    
    public func assign(_ value: Value) {
        self.attach(to: MutableBindable(with: value))
    }

    @objc public func updated() {
        guard let value = self.actual?.value else { return }
        self.wrappedValue.update(to: value)
    }
}

extension BindableProxy: ObservableValue {

    public func add(_ target: Any, selector: Selector) {
        self.wrappedValue.add(target, selector: selector)
    }
    public func remove(_ target: Any) {
        self.wrappedValue.remove(target)
    }
    public var value: Value {
        return self.wrappedValue.value
    }
}
