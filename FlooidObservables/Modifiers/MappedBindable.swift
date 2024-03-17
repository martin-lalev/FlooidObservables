//
//  MappedBindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 30.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

class MappedBindable<O1: ObservableValue,TargetType> {
    
    private let baseResults1: O1

    private let mapper: (O1.Value) -> TargetType
    
    private var wrappedValue: TargetType!
    
    private var observerToken: NSObjectProtocol?

    init(for baseResults1: O1, _ mapper: @escaping (O1.Value) -> TargetType) {
        self.baseResults1 = baseResults1
        
        self.mapper = mapper
        self.updateValue(baseResults1.value)

        self.observerToken = baseResults1.add { [weak self] value in
            guard let self = self else { return }
            self.updateValue(value)
        }
    }
    deinit {
        self.observerToken = nil
    }
    
    private func updateValue(_ value: O1.Value) {
        self.wrappedValue = self.mapper(value)
    }

}

extension MappedBindable: ObservableValue {
    
    var value: TargetType {
        return self.wrappedValue
    }
    
    func add(_ observer: @escaping (TargetType) -> Void) -> NSObjectProtocol {
        self.baseResults1.add { [weak self] value in
            guard let self = self else { return }
            observer(self.wrappedValue)
        }
    }
    
}

public extension ObservableValue {

    func map<TargetType>(_ processer: @escaping (Value) -> TargetType) -> some ObservableValue<TargetType> {
        return MappedBindable(for: self, processer)
    }
    
    func map<TargetType>(_ keyPath: KeyPath<Value, TargetType>) -> some ObservableValue<TargetType> {
        return MappedBindable(for: self, { value in value[keyPath: keyPath] })
    }
    
}

public extension ObservableValue {

    func mapUnwrapped<T,TargetType>(_ processer: @escaping (T) -> TargetType) -> some ObservableValue<TargetType?> where Value == T? {
        return MappedBindable(for: self) { $0.map(processer) }
    }
    
}

public extension ObservableValue where Value: Sequence {
    
    func mapEach<TargetType>(_ processer: @escaping (Value.Element) -> TargetType) -> some ObservableValue<[TargetType]> {
        return self.map { $0.map(processer) }
    }
    
    func compactMapEach<TargetType>(_ processer: @escaping (Value.Element) -> TargetType?) -> some ObservableValue<[TargetType]> {
        return self.map { $0.compactMap(processer) }
    }
    
    func sort(_ sorter: @escaping (Value.Element, Value.Element) -> Bool) -> some ObservableValue<[Value.Element]> {
        return self.map {
            return $0.sorted(by: sorter)
        }
    }

    func sort(_ sorter: @escaping (Value.Element, Value.Element) -> Bool?) -> some ObservableValue<[Value.Element]> {
        return self.sort { sorter($0,$1) ?? true }
    }
    
    func filter(_ filterer: @escaping (Value.Element) -> Bool) -> some ObservableValue<[Value.Element]> {
        return self.map {
            return $0.filter(filterer)
        }
    }

    func sort<T:Equatable>(byExistenceIn collection: some ObservableValue<[Value.Element]>, existingFirst: Bool = true, keyPath: KeyPath<Value.Element,T>) -> some ObservableValue<[Value.Element]> {
        #combine(self, collection).map { myItems, collectionItems in
            let mappedCollectionItems = collectionItems.map { $0[keyPath: keyPath] }
            return myItems.sorted(by: { mappedCollectionItems.contains($0[keyPath: keyPath]) == existingFirst && mappedCollectionItems.contains($1[keyPath: keyPath]) != existingFirst })
        }.asAny()
    }

}

public func keyPathCompare<V, T: Comparable>(_ obj0: V, _ obj1: V, _ keyPath: KeyPath<V,T>, _ ascending: Bool = true) -> Bool? {
    obj0[keyPath: keyPath] != obj1[keyPath: keyPath] ? ((obj0[keyPath: keyPath] < obj1[keyPath: keyPath]) == ascending) : nil
}

public extension Optional where Wrapped: ObservableValue {
    func asOptionalValue() -> (some ObservableValue<Wrapped.Value?>)? {
        return self?.asOptional()
    }
    func asOptional(defaultingTo value: Wrapped.Value?) -> some ObservableValue<Wrapped.Value?> {
        return (self?.asOptional()).defaultTo(value)
    }
    func defaultTo(_ value: Wrapped.Value) -> some ObservableValue<Wrapped.Value> {
        return self?.asAny() ?? MutableBindable(with: value).asAny()
    }
}

public extension ObservableValue {
    func asOptional() -> some ObservableValue<Value?> {
        return self.map { $0 as Value? }.asAny()
    }
}

public extension ObservableValue where Value == [String] {
    func join(separator: String) -> some ObservableValue<String> {
        return self.map { $0.joined(separator: separator) }.asAny()
    }
}

public extension ObservableValue {
    func asVoid() -> some ObservableValue<Void> { self.map { _ in () }.asAny() }
}
