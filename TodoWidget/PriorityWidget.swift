//
//  PriorityWidget.swift
//  TodoWidgetExtension
//
//  Created by 若江照仁 on 2022/03/13.
//

import WidgetKit
import SwiftUI

struct PriorityProvider: IntentTimelineProvider {
    typealias Intent = PrioritySelectionIntent
    typealias Entry = PriorityEntry

    func placeholder(in context: Context) -> PriorityEntry {
        dummyPriorityEntry
    }

    func getSnapshot(for configuration: PrioritySelectionIntent,
                     in context: Context,
                     completion: @escaping (PriorityEntry) -> Void) {
        if context.isPreview {
            completion(dummyPriorityEntry)
        } else {
            let todoList = try! fetchPriority(for: configuration)
            guard let priorityValue = configuration.priority?.intValue,
                  let priority = TodoPriority(rawValue: priorityValue) else {
                // todoはありません
                let entry = PriorityEntry(date: Date(), priority: .low, todoList: [])
                completion(entry)
                return
            }
            let entry = PriorityEntry(date: Date(), priority: priority, todoList: todoList)
            completion(entry)
        }
    }

    func getTimeline(for configuration: PrioritySelectionIntent,
                     in context: Context,
                     completion: @escaping (Timeline<PriorityEntry>) -> Void) {

        do {
            let todoList = try fetchPriority(for: configuration)
            print("priority: \(todoList.description)")
            let dividedTodoList = divideByThree(todoList: todoList)
            var entries: [PriorityEntry] = []
            dividedTodoList.forEach { (todoList) in
                if let lastTodo = todoList.last {
                    entries.append(PriorityEntry(date: lastTodo.startDate, priority: lastTodo.priority, todoList: todoList))
                } else {
                    let selectedPriority = TodoPriority(rawValue: configuration.priority!.intValue)!
                    let emptyEntry = PriorityEntry(date: Date(),
                                                   priority: selectedPriority,
                                                   todoList: [])
                    entries.append(emptyEntry)
                }
            }
            let timeLine = Timeline(entries: entries, policy: .atEnd)
            completion(timeLine)
        } catch {
            let entry = PriorityEntry(date: Date(), priority: .low, todoList: [])
            let timeLine = Timeline(entries: [entry], policy: .never)
            completion(timeLine)
            print(error.localizedDescription)
        }
    }

    func fetchPriority(for configuration: PrioritySelectionIntent) throws -> [TodoListItem] {
        if let priorityValue = configuration.priority?.intValue {
            let store = TodoListStore()
            do {
                let todoList = try store.fetchTodayItems(by: priorityValue)
                return todoList
            } catch {
                print(error.localizedDescription)
                throw error
            }
        } else {
            throw CoreDataStoreError.failureFetch
        }
    }

    // 3つずつ区切る
    func divideByThree(todoList: [TodoListItem]) -> [[TodoListItem]] {
        return stride(from: 0, to: todoList.count, by: 3).map {
            Array(todoList[$0..<min($0 + 3, todoList.count)])
        }
    }
}

struct PriorityEntry: TimelineEntry {
    let date: Date
    let priority: TodoPriority
    let todoList: [TodoListItem]
}

struct PriorityWidgetEntryView: View, TodoWidgetType {
    var entry: PriorityProvider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
            case .systemSmall:
                VStack {
                    if entry.todoList.isEmpty {
                        Text("今日のTodoはありません")
                            .padding(.bottom)
                    } else {
                        HStack(spacing: 4) {
                            VStack {
                                Circle()
                                    .foregroundColor(makePriorityColor(priority: entry.priority))
                                    .frame(width: 20, height: 30)
                                Spacer()
                            }
                            VStack(alignment: .leading) {
                                VStack(spacing: 8) {
                                    Text(entry.todoList.first!.title)
                                        .font(.title)
                                    Divider()
                                }
                                Spacer()
                            }
                        }
                        .widgetURL(makeURLScheme(id: entry.todoList.first!.id))
                    }

                    Text(entry.date, style: .date)
                        .font(.footnote)
                }
                .padding(.all)
            case .systemMedium:
                HStack {
                    Rectangle()
                        .foregroundColor(makePriorityColor(priority: entry.priority))
                        .overlay(
                            VStack {
                                Text("今日のTodo")
                                    .fontWeight(.bold)
                                Text("優先度: \(entry.priority.name)")
                                    .fontWeight(.bold)
                            }

                            .foregroundColor(.white)
                        )
                    if entry.todoList.isEmpty {
                        Text("今日のTodoはありません")
                            .padding()
                    } else {
                        VStack(alignment: .leading) {
                            ForEach(entry.todoList) { todoItem in
                                Link(destination: makeURLScheme(id: todoItem.id)!) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(todoItem.title)
                                            Text(todoItem.startDate, style: .time)
                                                .font(.caption)
                                        }
                                        Divider()
                                    }
                                }
                            }
                            Text(entry.date, style: .date)
                                .font(.footnote)
                        }
                    }
                }
            default:
                EmptyView()
        }
    }
}

struct PriorityWidget: Widget {
    let kind: String = "PriorityWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: PrioritySelectionIntent.self, provider: PriorityProvider()) { entry in
            PriorityWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Priority Sort")
        .description("今日のTodoを優先度ごとに表示")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

let dummyTodoItem: TodoListItem = .init(startDate: Date(),
                                        note: "",
                                        priority: .high,
                                        title: "Widget開発")

let dummyPriorityEntry: PriorityEntry = .init(date: Date(),
                                              priority: .high,
                                              todoList: [dummyTodoItem,
                                                         dummyTodoItem,
                                                         dummyTodoItem
                                              ])

let dummyEmptyEntry: PriorityEntry = .init(date: Date(), priority: .low, todoList: [])

struct PriorityWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PriorityWidgetEntryView(entry: dummyPriorityEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            PriorityWidgetEntryView(entry: dummyPriorityEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            PriorityWidgetEntryView(entry: dummyEmptyEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            PriorityWidgetEntryView(entry: dummyEmptyEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}

struct TodoCell: View {
    let todoTitle: String
    var body: some View {
        VStack(spacing: 8) {
            Text(todoTitle)
                .font(.title)
            Divider()
        }
    }
}

struct TodoMediumCell: View {
    let todoTitle: String
    let startDate: Date
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(todoTitle)
                Text(startDate, style: .time)
                    .font(.caption)
            }
            Divider()
        }
    }
}

struct PriorityCircle: View, TodoWidgetType {
    let priority: TodoPriority
    var body: some View {
        Circle()
            .foregroundColor(makePriorityColor(priority: priority))
            .frame(width: 20, height: 30)
    }
}
