//
//  BindableProxy.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 22.04.20.
//  Copyright © 2020 Martin Lalev. All rights reserved.
//

import Foundation
import Combine

public class BindableProxy<Value> {

    private let wrappedValue: MutableBindable<Value>
    private var actual: Bindable<Value>?
    private var cancellable: Any?
    private var observerToken: NSObjectProtocol?

    public init(with initialValue: Value) {
        self.wrappedValue = MutableBindable(with: initialValue)
    }
    deinit {
        self.observerToken = nil
        self.actual = nil
        self.cancellable = nil
    }

    public func attach<O: ObservableValue>(to observable: O?) where O.Value == Value {
        self.observerToken = nil
        self.actual = nil
        self.actual = observable?.asAny()
        self.observerToken = self.actual?.add { [weak self] value in
            guard let self = self else { return }
            self.updated(value)
        }
        if let value = self.actual?.value {
            updated(value)
        }
    }
    
    public func assign(_ value: Value) {
        self.attach(to: MutableBindable(with: value))
    }

    public func updated(_ value: Value) {
        self.wrappedValue.update(to: value)
    }

    @available(iOSApplicationExtension 13.0, *)
    public func attach<O: ObservableObject>(to observable: O, _ keyPath: KeyPath<O, Value>) {
        self.cancellable = observable.objectWillChange.sink(receiveValue: { [weak self] value in
            self?.wrappedValue.update(to: observable[keyPath: keyPath])
        })
        self.wrappedValue.update(to: observable[keyPath: keyPath])
    }
}

extension BindableProxy: ObservableValue {

    public var value: Value {
        return self.wrappedValue.value
    }
    
    public func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol {
        self.wrappedValue.add(observer)
    }
}
