//
//  Date+RecurringDue.swift
//  Tally
//
//  Created by Mazen Tarek on 4/5/26.
//

import Foundation

extension Date {

    // Attribution: GenAI helped me with this, but it essentially gets the current date and adds 31 days to it.
    static func nextRecurringDueDate(
        fromAnchor anchor: Date,
        stepDays: Int = 31,
        onOrAfter reference: Date = Date(),
        includeSameDayAsReference: Bool = true
    ) -> Date {
        let cal = Calendar.current
        let refStart = cal.startOfDay(for: reference)
        var due = cal.startOfDay(for: anchor)

        if includeSameDayAsReference {
            while due < refStart {
                guard let next = cal.date(byAdding: .day, value: stepDays, to: due) else { return refStart }
                due = cal.startOfDay(for: next)
            }
        } else {
            while due <= refStart {
                guard let next = cal.date(byAdding: .day, value: stepDays, to: due) else { return refStart }
                due = cal.startOfDay(for: next)
            }
        }
        return due
    }
}
