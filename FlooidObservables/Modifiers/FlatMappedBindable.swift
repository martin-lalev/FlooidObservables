//
//  FlatMappedBindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 30.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

class FlatMappedBindable<OV: ObservableValue, PV: ObservableValue> {

    private let wrapped: OV
    
    private let processer: (OV.Value) -> PV

    private var baseResults: PV
    private let dispatcher = MutableBindable(with: ())

    private var observerTokenBase: NSObjectProtocol?
    private var observerTokenWrapped: NSObjectProtocol?

    init(attachedTo observer: OV, _ processer: @escaping (OV.Value) -> PV) {
        self.processer = processer
        self.baseResults = processer(observer.value)
        self.wrapped = observer
        self.observerTokenBase = self.baseResults.add { [weak self] value in
            guard let self = self else { return }
            self.resultsChanged()
        }
        self.observerTokenWrapped = self.wrapped.add { [weak self] value in
            guard let self = self else { return }
            self.externalEvent(value)
        }
    }
    deinit {
        self.observerTokenBase = nil
        self.observerTokenWrapped = nil
    }
    
    @objc func resultsChanged() {
        self.dispatcher.update(to: ())
    }
    
    private func externalEvent(_ value: OV.Value) {
        self.observerTokenBase = nil
        self.baseResults = self.processer(value)
        self.observerTokenBase = self.baseResults.add { [weak self] value in
            guard let self = self else { return }
            self.resultsChanged()
        }
        self.dispatcher.update(to: ())
    }

}

extension FlatMappedBindable: ObservableValue {
    
    var value: PV.Value {
        return self.baseResults.value
    }
    
    func add(_ observer: @escaping (PV.Value) -> Void) -> NSObjectProtocol {
        self.dispatcher.add { [weak self] _ in
            guard let self = self else { return }
            observer(self.value)
        }
    }
    
}

public extension ObservableValue {
    
    func flatMap<T: ObservableValue>(_ mapper: @escaping (Value) -> T) -> some ObservableValue<T.Value> {
        return FlatMappedBindable(attachedTo: self, mapper)
    }
    
}

public extension ObservableValue {
    
    func flatMap<T: ObservableValue, TD: ObservableValue, V>(defaultTo defaultObservable: TD, _ mapper: @escaping (V) -> T) -> some ObservableValue<T.Value> where Value == V?, T.Value == TD.Value {
        return FlatMappedBindable(attachedTo: self) {
            if let value = $0 {
                return mapper(value).asAny()
            } else {
                return defaultObservable.asAny()
            }
        }
    }

    func flatMap<T: ObservableValue, V>(defaultTo defaultValue: T.Value, _ mapper: @escaping (V) -> T) -> some ObservableValue<T.Value> where Value == V? {
        return FlatMappedBindable(attachedTo: self) {
            if let value = $0 {
                return mapper(value).asAny()
            } else {
                return MutableBindable(with: defaultValue).asAny()
            }
        }
    }

}
