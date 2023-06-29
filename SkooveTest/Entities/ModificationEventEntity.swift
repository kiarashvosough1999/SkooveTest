//
//  ModificationEventEntity.swift
//  SkooveTest
//
//  Created by Kiarash Vosough on 6/29/23.
//

import Foundation

struct ModificationEventEntity: Equatable {
    let type: ModificationEventType
    let lineNumber: Int
    let newContent: String?
}
