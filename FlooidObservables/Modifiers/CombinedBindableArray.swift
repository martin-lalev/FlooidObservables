//
//  File.swift
//  
//
//  Created by Martin Lalev on 17/03/2024.
//

import Foundation

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
