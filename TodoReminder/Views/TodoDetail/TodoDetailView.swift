//
//  TodoDetailView.swift
//  TodoReminder
//
//  Created by 若江照仁 on 2022/03/12.
//

import SwiftUI

struct TodoDetailView: View {
    let todo: TodoListItem
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct TodoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TodoDetailView(todo: TodoListItem(startDate: Date(), note: "test for preview", priority: TodoPriority.high, title: "Test!!"))
    }
}
