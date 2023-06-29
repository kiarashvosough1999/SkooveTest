//
//  XCAsserts.swift
//  SkooveTestTests
//
//  Created by Kiarash Vosough on 6/29/23.
//

import XCTest

public func XCTAssertThrowsError<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTAssert(true, file: file, line: line)
    } catch {
        errorHandler(error)
    }
}

public func XCTAssertNoThrowsError<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
    } catch {
        XCTAssert(true, file: file, line: line)
    }
}
