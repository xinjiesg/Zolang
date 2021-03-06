//
//  FunctionMutationTests.swift
//  ZolangTests
//
//  Created by Þorvaldur Rúnarsson on 09/09/2018.
//

import Foundation
import XCTest
import ZolangCore

class FunctionMutationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFailure() {
        
        let invalidSamples: [(String, Int)] = [
            ("make some \n be something", 2),
            ("make \n some return something", 2),
            ("make some. return\n Some from (t as text) {}", 1),
            ("let\n some.some\n return Some from (t as text) {}", 1),
            ("\nmake \nsome.some. return text from (n as number)", 3),
            ("\nmake \nsome return \ntext from (\nn\n as )", 6)
        ]
        
        invalidSamples.forEach { (code, line) in
            var context = ParserContext(file: "test.zolang")
            let tokenList = code.zo.tokenize()
            do {
                _ = try FunctionMutation(tokens: tokenList, context: &context)
                XCTFail("Mutation should fail - \(tokenList)")
            } catch {
                XCTAssert((error as? ZolangError)?.line == line)
            }
        }

    }
    
    func testInit() {
        
        let samples: [(String, [String], Type, Int)] = [
            ("make some return Some from () {}", ["some"], .custom("Some"), 1),
            ("make some.someOther return \ntext from () {}", ["some", "someOther"], .primitive(.text), 2),
            ("make some\n.\nanother.another return list of number from \n\n() {}", ["some", "another", "another"], .list(.primitive(.number)), 5)
        ]
        
        for testTuple in samples {
            let (code, expectedIdentifiers, expectedType, endOfLine) = testTuple
            
            var context = ParserContext(file: "test.zolang")
            let tokenList = code.zo.tokenize()
            
            do {
                let mutation = try FunctionMutation(tokens: tokenList, context: &context)
                XCTAssert(context.line == endOfLine)
                
                XCTAssert(mutation.identifiers == expectedIdentifiers)
                
                guard mutation.newFunction.returnType == expectedType else {
                    XCTFail("VariableMutation resulted in wrong expression")
                    return
                }
                
            } catch {
                XCTFail("Should not fail to create FunctionMutation")
            }
        }
    }
}
