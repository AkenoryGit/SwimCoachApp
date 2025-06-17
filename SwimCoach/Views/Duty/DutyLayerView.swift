//
//  DutyLayerView.swift
//  SwimCoach
//
//  Created by Дмитрий Дудник on 26.05.2025.
//

import SwiftUI
import CoreData

struct DutyLayerView: View {
    @Binding var selectedDate: Date
    @Environment(\.managedObjectContext) private var viewContext
    private let hourHeight: CGFloat = 60
    @State private var duties: [Duty] = []

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                let positionedDuties = debugCalculatePositionedDuties(from: duties, hourHeight: hourHeight)

                ForEach(positionedDuties) { item in
                    DutyBlockView(
                        duty: item.duty,
                        topOffset: item.topOffset,
                        height: item.height,
                        availableWidth: geo.size.width * 0.15
                    )
                    .position(
                        x: geo.size.width - (geo.size.width * 0.15) / 2,
                        y: item.topOffset + item.height / 2
                    )
                }
            }
        }
        .onAppear(perform: fetchData)
        .onChange(of: selectedDate) { _ in fetchData() }
    }
    
    func debugCalculatePositionedDuties(from duties: [Duty], hourHeight: CGFloat) -> [PositionedDuty] {
        print("🟡 calculatePositionedDuties вызвана, всего \(duties.count) дежурств")
        return calculatePositionedDuties(from: duties, hourHeight: hourHeight)
    }

    private func fetchData() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let request = NSFetchRequest<Duty>(entityName: "Duty")
        request.predicate = NSPredicate(format: "startTime >= %@ AND startTime < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Duty.startTime, ascending: true)]

        do {
            duties = try viewContext.fetch(request)
        } catch {
            print("❌ Ошибка при загрузке дежурств: \(error)")
            duties = []
        }
    }
}
