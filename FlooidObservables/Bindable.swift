//
//  Bindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 31.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation
import Combine

public protocol ObservableValue {
    associatedtype Value
    var value: Value { get }
    func add(_ observer: Any, selector: Selector)
    func remove(_ observer: Any)
}

@propertyWrapper
@dynamicMemberLookup
public class Bindable<Value>: ObservableValue {
    
    var _value: () -> Value
    var _add: (Any, Selector) -> Void
    var _remove: (Any) -> Void
    
    init<Base: ObservableValue>(_ base: Base) where Base.Value == Value {
        self._value = { base.value }
        self._add = base.add
        self._remove = base.remove
    }
    
    public var wrappedValue: Value { self.value }
    
    public var projectedValue: Bindable<Value> { self }
    
    public func add(_ target: Any, selector: Selector) {
        self._add(target, selector)
    }
    public func remove(_ target: Any) {
        self._remove(target)
    }
    
    public var value: Value {
        return self._value()
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Value,T>) -> Bindable<T> { self.map { $0[keyPath: keyPath] }.asAny() }
}

public extension ObservableValue {
    func asAny() -> Bindable<Value> { return Bindable(self) }
}

public typealias BindableList<T> = Bindable<[T]>

@available(iOS 13.0, iOSApplicationExtension 13.0, *)
extension Bindable: Publisher {
    public typealias Output = Value
    public typealias Failure = Never

    public func receive<S: Combine.Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = BindableSubscription<Value, S>()
        subscription.target = subscriber
        subscriber.receive(subscription: subscription)
        self.add(subscription, selector: #selector(subscription.trigger))
    }

    class BindableSubscription<Value, Target: Combine.Subscriber>: Subscription where Target.Input == Value {
        weak var bindable: Bindable<Value>?

        func attach(to bindable: Bindable<Value>) {
            self.bindable = bindable
            bindable.add(self, selector: #selector(trigger))
        }

        var target: Target?
        func request(_ demand: Subscribers.Demand) {}
        func cancel() { bindable?.remove(self) }

        @objc func trigger() {
            guard let value = bindable?.value else { return }
            _ = target?.receive(value)
        }
    }
}
