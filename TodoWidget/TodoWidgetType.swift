//
//  TodoWidgetType.swift
//  TodoReminder
//
//  Created by 若江照仁 on 2022/03/13.
//

import SwiftUI

protocol TodoWidgetType {
    func makePriorityColor(priority: TodoPriority) -> Color
    func makeURLScheme(id: UUID) -> URL?
}

extension TodoWidgetType where Self: View {
    func makePriorityColor(priority: TodoPriority) -> Color {
        switch priority {
            case .high:
                return .red
            case .medium:
                return .yellow
            case .low:
                return .green
        }
    }

    func makeURLScheme(id: UUID) -> URL? {
        guard let url = URL(string: "todolist://detail") else {
            return nil
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [URLQueryItem(name: "id", value: id.uuidString)]
        return urlComponents?.url
    }
}
