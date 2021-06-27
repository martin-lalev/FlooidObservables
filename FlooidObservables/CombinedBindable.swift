//
//  CombinedBindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 21.06.20.
//  Copyright © 2020 Martin Lalev. All rights reserved.
//

import Foundation

public class Combined2Bindables<O1: ObservableValue, O2: ObservableValue>: ObservableValue {
    
    private let baseResults: (O1,O2)
    
    private class Token: NSObject {
        let o1: NSObjectProtocol
        let o2: NSObjectProtocol
        init(_ o1: NSObjectProtocol, _ o2: NSObjectProtocol) {
            self.o1 = o1
            self.o2 = o2
            super.init()
        }
    }

    public init(_ baseResults1: O1, _ baseResults2: O2) {
        self.baseResults = (baseResults1, baseResults2)
    }
    
    public var value: (O1.Value,O2.Value) {
        return (self.baseResults.0.value,self.baseResults.1.value)
    }
    
    public func add(_ observer: @escaping ((O1.Value, O2.Value)) -> Void) -> NSObjectProtocol {
        Token(
            self.baseResults.0.add { [weak self] _ in
                guard let self = self else { return }
                observer(self.value)
            },
            self.baseResults.1.add { [weak self] _ in
                guard let self = self else { return }
                observer(self.value)
            }
        )
    }
    
}

public class Combined3Bindables<O1: ObservableValue, O2: ObservableValue, O3: ObservableValue>: ObservableValue {
    
    private let baseResults: (O1,O2,O3)
    
    private class Token: NSObject {
        let o1: NSObjectProtocol
        let o2: NSObjectProtocol
        let o3: NSObjectProtocol
        init(_ o1: NSObjectProtocol, _ o2: NSObjectProtocol, _ o3: NSObjectProtocol) {
            self.o1 = o1
            self.o2 = o2
            self.o3 = o3
            super.init()
        }
    }

    public init(_ baseResults1: O1, _ baseResults2: O2, _ baseResults3: O3) {
        self.baseResults = (baseResults1, baseResults2, baseResults3)
    }
    
    public var value: (O1.Value,O2.Value,O3.Value) {
        return (self.baseResults.0.value,self.baseResults.1.value,self.baseResults.2.value)
    }
    
    public func add(_ observer: @escaping ((O1.Value, O2.Value, O3.Value)) -> Void) -> NSObjectProtocol {
        Token(
            self.baseResults.0.add { [weak self] _ in
                guard let self = self else { return }
                observer(self.value)
            },
            self.baseResults.1.add { [weak self] _ in
                guard let self = self else { return }
                observer(self.value)
            },
            self.baseResults.2.add { [weak self] _ in
                guard let self = self else { return }
                observer(self.value)
            }
        )
    }

}

public class CombinedArrayBindables<O: ObservableValue>: ObservableValue {
    
    private let baseResults: [O]
    
    private class Token: NSObject {
        let os: [NSObjectProtocol]
        init(_ os: [NSObjectProtocol]) {
            self.os = os
            super.init()
        }
    }

    public init(_ baseResults: [O]) {
        self.baseResults = baseResults
    }
    
    public var value: [O.Value] {
        return self.baseResults.map { $0.value }
    }
    
    public func add(_ observer: @escaping ([O.Value]) -> Void) -> NSObjectProtocol {
        Token(
            self.baseResults.map {
                $0.add { [weak self] _ in
                    guard let self = self else { return }
                    observer(self.value)
                }
            }
        )
    }

}

public func combine<O1: ObservableValue, O2: ObservableValue>(_ observable1: O1, _ observable2: O2) -> Combined2Bindables<O1, O2> {
    return .init(observable1, observable2)
}

public func combine<O1: ObservableValue, O2: ObservableValue, O3: ObservableValue>(_ observable1: O1, _ observable2: O2, _ observable3: O3) -> Combined3Bindables<O1, O2, O3> {
    return .init(observable1, observable2, observable3)
}

public func combine<O: ObservableValue>(_ observables: [O]) -> CombinedArrayBindables<O> {
    return .init(observables)
}

public extension Combined2Bindables {
    func map<TargetType>(_ processer: @escaping (O1.Value, O2.Value) -> TargetType) -> MappedBindable<Combined2Bindables<O1, O2>, TargetType> {
        self.map { processer($0.0, $0.1) }
    }
    func map<O: AnyObject, TargetType>(_ object: O, _ processer: @escaping (O, O1.Value, O2.Value) -> TargetType) -> MappedBindable<Combined2Bindables<O1, O2>, TargetType> {
        self.map { [weak object] in
            guard let object = object else { fatalError() }
            return processer(object, $0.0, $0.1)
        }
    }
}

public extension Combined3Bindables {
    func map<TargetType>(_ processer: @escaping (O1.Value, O2.Value, O3.Value) -> TargetType) -> MappedBindable<Combined3Bindables<O1, O2, O3>, TargetType> {
        self.map { processer($0.0, $0.1, $0.2) }
    }
    func map<O: AnyObject, TargetType>(_ object: O, _ processer: @escaping (O, O1.Value, O2.Value, O3.Value) -> TargetType) -> MappedBindable<Combined3Bindables<O1, O2, O3>, TargetType> {
        self.map { [weak object] in
            guard let object = object else { fatalError() }
            return processer(object, $0.0, $0.1, $0.2)
        }
    }
}

public extension Array where Element: ObservableValue {
    func merge() -> CombinedArrayBindables<Element> {
        return combine(self)
    }
}
