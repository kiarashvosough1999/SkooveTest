//
//  FetchUserIDRepositoryStub.swift
//  SkooveTestTests
//
//  Created by Kiarash Vosough on 6/29/23.
//

import Foundation
@testable import SkooveTest

final class FetchUserIDRepositoryStub {
    var errorToThrow: Error?

    var id: Int = .zero

    init(errorToThrow: Error? = nil) {
        self.errorToThrow = errorToThrow
    }
}

extension FetchUserIDRepositoryStub: FetchUserIDRepositoryProtocol {
    func fetchUserId() async throws -> Int {
        if let errorToThrow { throw errorToThrow }
        return id
    }
}
