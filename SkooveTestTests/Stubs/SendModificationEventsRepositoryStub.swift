//
//  SendModificationEventsRepositoryStub.swift
//  SkooveTestTests
//
//  Created by Kiarash Vosough on 6/29/23.
//

import Foundation
@testable import SkooveTest

final class SendModificationEventsRepositoryStub {
    var modelReceived: UserModificationEventEntity?
    var errorToThrow: Error?
}

extension SendModificationEventsRepositoryStub: SendModificationEventsRepositoryProtocol {

    func modify(with model: UserModificationEventEntity) async throws {
        if let errorToThrow { throw errorToThrow }
        modelReceived = model
    }
}
