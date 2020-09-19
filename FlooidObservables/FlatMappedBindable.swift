//
//  FlatMappedBindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 30.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

public class FlatMappedBindable<OV: ObservableValue, PV: ObservableValue> {

    private let wrapped: OV
    
    private let processer: (OV.Value) -> PV

    private var baseResults: PV
    private let dispatcher = MutableBindable(with: ())

    init(attachedTo observer: OV, _ processer: @escaping (OV.Value) -> PV) {
        self.processer = processer
        self.baseResults = processer(observer.value)
        self.wrapped = observer
        self.baseResults.add(self, selector: #selector(self.resultsChanged))
        self.wrapped.add(self, selector: #selector(externalEvent))
    }
    deinit {
        self.baseResults.remove(self)
        self.wrapped.remove(self)
    }
    
    @objc func resultsChanged() {
        self.dispatcher.update(to: ())
    }
    
    @objc private func externalEvent() {
        self.baseResults.remove(self)
        self.baseResults = self.processer(self.wrapped.value)
        self.baseResults.add(self, selector: #selector(self.resultsChanged))
        self.dispatcher.update(to: ())
    }

}

extension FlatMappedBindable: ObservableValue {
    
    public func add(_ observer: Any, selector: Selector) {
        self.dispatcher.add(observer, selector: selector)
    }
    public func remove(_ observer: Any) {
        self.dispatcher.remove(observer)
    }
    public var value: PV.Value {
        return self.baseResults.value
    }
    
}

public extension ObservableValue {
    
    func flatMap<T: ObservableValue>(_ mapper: @escaping (Value) -> T) -> FlatMappedBindable<Self, T> {
        return FlatMappedBindable(attachedTo: self, mapper)
    }
    
    func flatMap<T: ObservableValue, O: AnyObject>(_ object: O, _ mapper: @escaping (O, Value) -> T) -> FlatMappedBindable<Self, T> {
        return FlatMappedBindable(attachedTo: self) { [unowned object] in mapper(object, $0) }
    }
    
}

public extension ObservableValue {
    
    func flatMap<T: ObservableValue, TD: ObservableValue, V>(defaultTo defaultObservable: TD, _ mapper: @escaping (V) -> T) -> FlatMappedBindable<Self, Bindable<T.Value>> where Value == V?, T.Value == TD.Value {
        return FlatMappedBindable(attachedTo: self) {
            if let value = $0 {
                return mapper(value).asAny()
            } else {
                return defaultObservable.asAny()
            }
        }
    }

    func flatMap<T: ObservableValue, V>(defaultTo defaultValue: T.Value, _ mapper: @escaping (V) -> T) -> FlatMappedBindable<Self, Bindable<T.Value>> where Value == V? {
        return FlatMappedBindable(attachedTo: self) {
            if let value = $0 {
                return mapper(value).asAny()
            } else {
                return MutableBindable(with: defaultValue).asAny()
            }
        }
    }
    
    func flatMap<T: ObservableValue, TD: ObservableValue, O: AnyObject, V>(defaultTo defaultObservable: TD, _ object: O, _ mapper: @escaping (O, V) -> T) -> FlatMappedBindable<Self, Bindable<T.Value>> where Value == V?, T.Value == TD.Value {
        return FlatMappedBindable(attachedTo: self) {
            if let value = $0 {
                return mapper(object, value).asAny()
            } else {
                return defaultObservable.asAny()
            }
        }
    }

    func flatMap<T: ObservableValue, O: AnyObject, V>(defaultTo defaultValue: T.Value, _ object: O, _ mapper: @escaping (O, V) -> T) -> FlatMappedBindable<Self, Bindable<T.Value>> where Value == V? {
        return FlatMappedBindable(attachedTo: self) {
            if let value = $0 {
                return mapper(object, value).asAny()
            } else {
                return MutableBindable(with: defaultValue).asAny()
            }
        }
    }

}
