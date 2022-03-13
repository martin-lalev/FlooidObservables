//
//  File.swift
//  
//
//  Created by Martin Lalev on 12/03/2022.
//

import Foundation

public class ObservableModelDispatcher {
    let objectWillUpdate = MutableBindable(with: ())
    var updateRequested = false
    func update() {
        updateRequested = true
        DispatchQueue.main.async {
            guard self.updateRequested else { return }
            self.updateRequested = false
            self.objectWillUpdate.update(to: ())
        }
    }
}

private protocol ObservableModelProperty {
    var objectWillUpdate: ObservableModelDispatcher? { get nonmutating set }
}

extension Observed: ObservableModelProperty {
    var objectWillUpdate: ObservableModelDispatcher? {
        get { projectedValue.bindable.objectWillUpdate }
        nonmutating set { projectedValue.bindable.objectWillUpdate = newValue }
    }
}

extension ObservableModelType {

    public var objectWillUpdate: MutableBindable<Void> {
        var mirrorV: Mirror? = Mirror(reflecting: self)
        while let mirror = mirrorV {
            let observableProperties = mirror.children.compactMap {
                $0.value as? ObservableModelProperty
            }.filter { $0.objectWillUpdate == nil }

            for property in observableProperties {
                property.objectWillUpdate = self.objectWillUpdateStorage
            }
            mirrorV = mirror.superclassMirror
        }
        return self.objectWillUpdateStorage.objectWillUpdate
    }
}
