//
//  File.swift
//  
//
//  Created by Martin Lalev on 16/03/2024.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CombineObservblesExpressionMacro.self
    ]
}
