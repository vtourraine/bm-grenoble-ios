//
//  LoansWidget.swift
//  LoansWidget
//
//  Created by Vincent Tourraine on 12/05/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import Foundation
import WidgetKit
import SwiftUI
import BMKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), loan: nil, signedIn: true, numberOfLoanedDocuments: 0, image: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        guard let credentials = Credentials.sharedCredentials() else {
            let entry = SimpleEntry(date: Date(), loan: nil, signedIn: false, numberOfLoanedDocuments: 0, image: nil)
            completion(entry)
            return
        }

        Item.fetchItems(with: credentials) { result in
            switch result {
            case .success(let items):
                let entry = SimpleEntry(date: Date(), loan: items.first, signedIn: true, numberOfLoanedDocuments: 0, image: nil)
                completion(entry)

            case .failure:
                let entry = SimpleEntry(date: Date(), loan: nil, signedIn: false, numberOfLoanedDocuments: 0, image: nil)
                completion(entry)
                return
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let policy = TimelineReloadPolicy.after(Date().addingTimeInterval(60*60))

        guard let credentials = Credentials.sharedCredentials() else {
            let timeline = Timeline(entries: [SimpleEntry](), policy: policy)
            completion(timeline)
            return
        }

        Item.fetchItems(with: credentials) { result in
            switch result {
            case .success(let items):
                let entry = SimpleEntry(date: Date(), loan: items.first, signedIn: true, numberOfLoanedDocuments: items.count, image: nil)
                let timeline = Timeline(entries: [entry], policy: policy)
                completion(timeline)

            case .failure:
                let timeline = Timeline(entries: [SimpleEntry](), policy: policy)
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let loan: Item?
    let signedIn: Bool
    let numberOfLoanedDocuments: Int
    let image: Image?
}

struct MessageView: View {
    let text: String

    var body: some View {
        ZStack {
            Color("WidgetBackground")
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}


struct LoansWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if !entry.signedIn {
            MessageView(text: "Please open the app to sign in.")
        }
        else if entry.numberOfLoanedDocuments == 0 {
            MessageView(text: "No Current Loans")
        }
        else if let loan = entry.loan {
            ZStack {
                Color("WidgetBackground")
                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(loan.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(loan.author)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Text("Due: \(loan.returnDateComponents.formattedReturnDate()!.localizedDate)")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("\(entry.numberOfLoanedDocuments) books loaned")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
            }
        }
        else {
            MessageView(text: "Error Loading Widget")
        }
    }
}

@main
struct LoansWidget: Widget {
    let kind: String = "LoansWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LoansWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Loans Widget")
        .description("Shows you a list of the documents you currently loan.")
    }
}

struct LoansWidget_Previews: PreviewProvider {
    static let item = Item(identifier: "", isRenewable: false, title: "Test", type: "book", author: "No Body", library: "Library", returnDateComponents: DateComponents(calendar: nil, timeZone: nil, era: nil, year: 2021, month: 01, day: 01), image: nil)

    static var previews: some View {
        LoansWidgetEntryView(entry: SimpleEntry(date: Date(), loan: item, signedIn: false, numberOfLoanedDocuments: 5, image: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        LoansWidgetEntryView(entry: SimpleEntry(date: Date(), loan: item, signedIn: true, numberOfLoanedDocuments: 5, image: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
