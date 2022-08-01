//
//  LoansWidget.swift
//  LoansWidget
//
//  Created by Vincent Tourraine on 12/05/2021.
//  Copyright © 2021-2022 Studio AMANgA. All rights reserved.
//

import Foundation
import WidgetKit
import SwiftUI
import BMKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let item = Item(identifier: "", isRenewable: false, title: "My Favorite Book", type: "book", author: "Jane Doe", library: "Library", returnDateComponents: DateComponents(calendar: nil, timeZone: nil, era: nil, year: 2021, month: 01, day: 01), image: nil)
        return SimpleEntry(date: Date(), loan: item, signedIn: true, numberOfLoanedDocuments: 1)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        guard let session = Session.sharedSession() else {
            let entry = placeholder(in: context)
            completion(entry)
            return
        }

        let urlSession = URLSession.shared
        urlSession.fetchItems(with: session) { result in
            switch result {
            case .success(let items):
                let entry = SimpleEntry(date: Date(), loan: items.first, signedIn: true, numberOfLoanedDocuments: items.count)
                completion(entry)

            case .failure:
                let entry = SimpleEntry(date: Date(), loan: nil, signedIn: false)
                completion(entry)
                return
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let policy = TimelineReloadPolicy.after(Date().addingTimeInterval(60*60*12))

        guard let session = Session.sharedSession() else {
            let timeline = Timeline(entries: [SimpleEntry(date: Date(), loan: nil, signedIn: false)], policy: policy)
            completion(timeline)
            return
        }

        let urlSession = URLSession.shared
        urlSession.fetchItems(with: session) { result in
            switch result {
            case .success(let items):
                let entry = SimpleEntry(date: Date(), loan: items.first, signedIn: true, numberOfLoanedDocuments: items.count)
                let timeline = Timeline(entries: [entry], policy: policy)
                completion(timeline)

            case .failure(let error):
                let text: String
                if (error as? NetworkError) == NetworkError.forbidden {
                    text = "Please open the app to sign in."
                }
                else {
                    text = "Cannot Refresh Loans (\(error.localizedDescription))"
                }
                
                let timeline = Timeline(entries: [SimpleEntry(date: Date(), text: text)], policy: policy)
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
    let text: String?
}

extension SimpleEntry {
    init(date: Date, loan: Item?, signedIn: Bool, numberOfLoanedDocuments: Int = 0) {
        self.init(date: date, loan: loan, signedIn: signedIn, numberOfLoanedDocuments: numberOfLoanedDocuments, text: nil)
    }
    
    init(date: Date, text: String) {
        self.init(date: date, loan: nil, signedIn: false, numberOfLoanedDocuments: 0, text: text)
    }
}

struct MessageView: View {
    let text: LocalizedStringKey

    var body: some View {
        ZStack(alignment: .top) {
            Color("WidgetBackground")
            HStack {
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                Spacer()
            }
        }
    }
}


struct LoansWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if let text = entry.text {
            MessageView(text: LocalizedStringKey(text))
        }
        else if !entry.signedIn {
            MessageView(text: "Please open the app to sign in.")
        }
        else if entry.numberOfLoanedDocuments == 0 {
            MessageView(text: "No Current Loans")
        }
        else if let loan = entry.loan {
            ZStack {
                Color("WidgetBackground")
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loan.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(loan.author)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Text("Due: \(loan.returnDateComponents.formattedReturnDate()!.localizedDate)")
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(entry.numberOfLoanedDocuments) documents loaned")
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
        .description("Displays documents currently loaned.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct LoansWidget_Previews: PreviewProvider {
    static let item = Item(identifier: "", isRenewable: false, title: "My Favorite Book in the World", type: "book", author: "No Body", library: "Library", returnDateComponents: DateComponents(calendar: nil, timeZone: nil, era: nil, year: 2021, month: 01, day: 01), image: nil)

    static var previews: some View {
        LoansWidgetEntryView(entry: SimpleEntry(date: Date(), loan: item, signedIn: false, numberOfLoanedDocuments: 5))
            // .environment(\.locale, .init(identifier: "fr"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        LoansWidgetEntryView(entry: SimpleEntry(date: Date(), loan: nil, signedIn: true, numberOfLoanedDocuments: 0))
            // .environment(\.locale, .init(identifier: "fr"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        LoansWidgetEntryView(entry: SimpleEntry(date: Date(), loan: item, signedIn: true, numberOfLoanedDocuments: 5))
            .environment(\.locale, .init(identifier: "fr"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
