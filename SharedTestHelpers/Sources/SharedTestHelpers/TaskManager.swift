//
//  TaskManager.swift
//  
//
//  Created by Ben on 17/01/2023.
//

import Foundation

@available(iOS 13, *)
public class TaskManager {
    public var ignoreNewTasks = false

    private var taskClosures = [() async -> Void]()

    public init() {}

    public func createTask(_ closure: @escaping () async -> Void) {
        if ignoreNewTasks {
            return
        }

        taskClosures.append(closure)
    }

    public func awaitCurrentTasks() async {
        while let taskClosure = taskClosures.popLast() {
            _ = await Task {
                await taskClosure()
            }.result
        }
    }
}
