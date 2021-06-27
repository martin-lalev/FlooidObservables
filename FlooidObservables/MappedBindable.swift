//
//  MappedBindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 30.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

public class MappedBindable<O1: ObservableValue,TargetType> {
    
    private let baseResults1: O1

    private let mapper: (O1.Value) -> TargetType
    
    private var wrappedValue: TargetType!
    
    private var observerToken: NSObjectProtocol?

    public init(for baseResults1: O1, _ mapper: @escaping (O1.Value) -> TargetType) {
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
    
    public var value: TargetType {
        return self.wrappedValue
    }
    
    public func add(_ observer: @escaping (TargetType) -> Void) -> NSObjectProtocol {
        self.baseResults1.add { [weak self] value in
            guard let self = self else { return }
            observer(self.wrappedValue)
        }
    }
    
}

extension ObservableValue {

    public func map<TargetType>(_ processer: @escaping (Value) -> TargetType) -> MappedBindable<Self,TargetType> {
        return MappedBindable(for: self, processer)
    }
    
    public func map<TargetType, O: AnyObject>(_ object: O, _ processer: @escaping (O, Value) -> TargetType) -> MappedBindable<Self,TargetType> {
        return MappedBindable(for: self) { [unowned object] in processer(object, $0) }
    }
    
}

extension ObservableValue {

    public func mapUnwrapped<T,TargetType>(_ processer: @escaping (T) -> TargetType) -> MappedBindable<Self,TargetType?> where Value == T? {
        return MappedBindable(for: self) { $0.map(processer) }
    }
    
    public func mapUnwrapped<T,TargetType, O: AnyObject>(_ object: O, _ processer: @escaping (O, T) -> TargetType) -> MappedBindable<Self,TargetType?> where Value == T? {
        return MappedBindable(for: self) { [unowned object] in $0.map { processer(object, $0) } }
    }
    
}

extension ObservableValue where Value: Sequence {
    
    public func mapEach<TargetType>(_ processer: @escaping (Value.Element) -> TargetType) -> MappedBindable<Self,[TargetType]> {
        return self.map { $0.map(processer) }
    }
    
    public func compactMapEach<TargetType>(_ processer: @escaping (Value.Element) -> TargetType?) -> MappedBindable<Self,[TargetType]> {
        return self.map { $0.compactMap(processer) }
    }
    
    public func mapEach<TargetType, O: AnyObject>(_ object: O, _ processer: @escaping (O, Value.Element) -> TargetType) -> MappedBindable<Self,[TargetType]> {
        return self.map { [weak object] in
            guard let object = object else { return [] }
            return $0.map {
                processer(object, $0)
            }
        }
    }
    
    public func compactMapEach<TargetType, O: AnyObject>(_ object: O, _ processer: @escaping (O, Value.Element) -> TargetType?) -> MappedBindable<Self,[TargetType]> {
        return self.map { [weak object] in
            guard let object = object else { return [] }
            return $0.compactMap {
                processer(object, $0)
            }
        }
    }
    
    public func sort(_ sorter: @escaping (Value.Element, Value.Element) -> Bool) -> MappedBindable<Self,[Value.Element]> {
        return self.map {
            return $0.sorted(by: sorter)
        }
    }

    public func sort(_ sorter: @escaping (Value.Element, Value.Element) -> Bool?) -> MappedBindable<Self,[Value.Element]> {
        return self.sort { sorter($0,$1) ?? true }
    }
    
    public func filter(_ filterer: @escaping (Value.Element) -> Bool) -> MappedBindable<Self,[Value.Element]> {
        return self.map {
            return $0.filter(filterer)
        }
    }

    public func filter<O: AnyObject>(_ object: O, _ filterer: @escaping (O, Value.Element) -> Bool) -> MappedBindable<Self,[Value.Element]> {
        return self.map(object) { objectt, items in
            return items.filter {
                filterer(objectt, $0)
            }
        }
    }
    
    public func sort<T:Equatable, O: ObservableValue>(byExistenceIn collection: O, existingFirst: Bool = true, keyPath: KeyPath<Value.Element,T>) -> Bindable<[Value.Element]> where O.Value == [Value.Element] {
        combine(self, collection).map { myItems, collectionItems in
            let mappedCollectionItems = collectionItems.map { $0[keyPath: keyPath] }
            return myItems.sorted(by: { mappedCollectionItems.contains($0[keyPath: keyPath]) == existingFirst && mappedCollectionItems.contains($1[keyPath: keyPath]) != existingFirst })
        }.asAny()
    }

}

public func keyPathCompare<V, T: Comparable>(_ obj0: V, _ obj1: V, _ keyPath: KeyPath<V,T>, _ ascending: Bool = true) -> Bool? {
    obj0[keyPath: keyPath] != obj1[keyPath: keyPath] ? ((obj0[keyPath: keyPath] < obj1[keyPath: keyPath]) == ascending) : nil
}

public extension Optional where Wrapped: ObservableValue {
    func asOptionalValue() -> Bindable<Wrapped.Value?>? {
        return self?.asOptional()
    }
    func asOptional(defaultingTo value: Wrapped.Value?) -> Bindable<Wrapped.Value?> {
        return (self?.asOptional()).defaultTo(value)
    }
    func defaultTo(_ value: Wrapped.Value) -> Bindable<Wrapped.Value> {
        return self?.asAny() ?? MutableBindable(with: value).asAny()
    }
}

public extension ObservableValue {
    func asOptional() -> Bindable<Value?> {
        return self.map { $0 as Value? }.asAny()
    }
}

public extension ObservableValue where Value == [String] {
    func join(separator: String) -> Bindable<String> {
        return self.map { $0.joined(separator: separator) }.asAny()
    }
}

public extension ObservableValue {
    func asVoid() -> Bindable<Void> { self.map { _ in () }.asAny() }
}
