//
//  File.swift
//  
//
//  Created by Martin Lalev on 16/03/2024.
//

import SwiftSyntaxMacros
import SwiftSyntax

public struct CombineObservblesExpressionMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> SwiftSyntax.ExprSyntax {
        let count = node.argumentList.count
        
        let args = node.argumentList.map { expr in
            expr.expression
        }
        
        let combinersNames = (2...count)
            .map { ind in "combine(with: \(args[ind-1].description))" }
            .joined(separator: ".")
        
        let mappedArguments = (1...count)
            .map { ind in "$0\(String(repeating: ".0", count: count-ind))\(ind == 1 ? "" : ".1")" }
            .joined(separator: ", ")

        return "\(raw: args[0].description).\(raw: combinersNames).map { (\(raw: mappedArguments)) }.asAny()"
    }
}
