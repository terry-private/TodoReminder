//
//  TodoWidgetBundle.swift
//  TodoWidgetExtension
//
//  Created by 若江照仁 on 2022/03/13.
//

import WidgetKit
import SwiftUI

@main
struct TodoWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodoWidget()
        PriorityWidget()
    }
}
