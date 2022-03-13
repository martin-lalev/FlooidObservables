//
//  File.swift
//  
//
//  Created by Martin Lalev on 12/03/2022.
//

import Foundation

@propertyWrapper
public struct Observed<Value> {

    var bindableWrapper: PublishedBindableWrapper
    
    public init(wrappedValue: Value) {
        self.bindableWrapper = PublishedBindableWrapper(wrappedValue)
    }
    public init(initialValue: Value) {
        self.init(wrappedValue: initialValue)
    }

    public var projectedValue: PublishedBindableWrapper {
        get { bindableWrapper }
        set { }
    }

    @available(*, unavailable, message: "@Published can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    public static subscript<T: ObservableModelType>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get { instance[keyPath: storageKeyPath].bindableWrapper.bindable.value }
        set { instance[keyPath: storageKeyPath].bindableWrapper.bindable.assign(to: newValue) }
    }
    
    public struct PublishedBindableWrapper {
        let bindable: PublishedBindable<Value>
        init(_ output: Value) {
            self.bindable = .init(with: output)
        }
    }

    class PublishedBindable<Value> {
        var token: NSObjectProtocol?
        var dispatcherBindable: Bindable<Value>
        
        var objectWillUpdate: ObservableModelDispatcher?
        
        init(with value: Value) {
            self.dispatcherBindable = MutableBindable(with: value).asAny()
            self.didSetBindable()
        }

        private func didSetBindable() {
            self.token = self.dispatcherBindable.add { [weak self] _ in
                self?.objectWillUpdate?.update()
            }
            self.objectWillUpdate?.update()
        }

        func assign(to value: Value) {
            self.dispatcherBindable = MutableBindable(with: value).asAny()
            self.didSetBindable()
        }
        func attach<O: ObservableValue>(_ observer: O) where O.Value == Value {
            self.dispatcherBindable = observer.asAny()
            self.didSetBindable()
        }

        var value: Value {
            self.dispatcherBindable.value
        }
    }
}

extension ObservableValue {
    public func assign(to mutable: inout Observed<Value>.PublishedBindableWrapper) {
        mutable.bindable.attach(self)
    }
}
