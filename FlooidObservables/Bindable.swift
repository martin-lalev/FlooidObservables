//
//  Bindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 31.10.19.
//  Copyright © 2019 Martin Lalev. All rights reserved.
//

import Foundation

public class AnyObservableValue<Value> {
    var base: any ObservableValue<Value>
    init(_ base: some ObservableValue<Value>) {
        self.base = base
    }
}
extension AnyObservableValue: ObservableValue {
    public func add(_ observer: @escaping (Value) -> Void) -> NSObjectProtocol {
        base.add(observer)
    }
    
    public var value: Value {
        base.value
    }
}

public extension ObservableValue {
    func asAny() -> AnyObservableValue<Value> { return AnyObservableValue(self) }
}

public typealias Bindable = AnyObservableValue
