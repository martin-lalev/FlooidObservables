//
//  CombinedBindable.swift
//  DandaniaUtils
//
//  Created by Martin Lalev on 21.06.20.
//  Copyright © 2020 Martin Lalev. All rights reserved.
//

import Foundation

class CombinedBindable<O1: ObservableValue, O2: ObservableValue>: ObservableValue {
    
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

    init(_ baseResults1: O1, _ baseResults2: O2) {
        self.baseResults = (baseResults1, baseResults2)
    }
    
    var value: (O1.Value,O2.Value) {
        return (self.baseResults.0.value,self.baseResults.1.value)
    }
    
    func add(_ observer: @escaping ((O1.Value, O2.Value)) -> Void) -> NSObjectProtocol {
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

public extension ObservableValue {
    func combine<O: ObservableValue>(with observable: O) -> some ObservableValue<(Value, O.Value)> {
        return CombinedBindable(self, observable)
    }
}

@freestanding(expression)
public macro combine<each O: ObservableValue>(
    _ b: repeat each O
) -> Bindable<(repeat (each O).Value)> = #externalMacro(module: "FlooidObservablesMacros", type: "CombineObservblesExpressionMacro")

class CombinedBindableArray<O: ObservableValue>: ObservableValue {
    
    private let baseResults: [O]
    
    private class Token: NSObject {
        let os: [NSObjectProtocol]
        init(_ os: [NSObjectProtocol]) {
            self.os = os
            super.init()
        }
    }

    init(_ baseResults: [O]) {
        self.baseResults = baseResults
    }
    
    var value: [O.Value] {
        return self.baseResults.map { $0.value }
    }
    
    func add(_ observer: @escaping ([O.Value]) -> Void) -> NSObjectProtocol {
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

public extension Array where Element: ObservableValue {
    func merge() -> some ObservableValue<[Element.Value]> {
        return CombinedBindableArray(self)
    }
}
