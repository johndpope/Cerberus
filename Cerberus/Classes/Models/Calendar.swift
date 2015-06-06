import Foundation
import EventKit
import Timepiece

enum CalendarAuthorizationStatus {
    case Success
    case Error
}

final class Calendar {
    var events: [Event]!

    var eventStore: EKEventStore!
    var calendar: NSCalendar!

    init() {
        self.events = []
        self.eventStore = EKEventStore()
        self.calendar = NSCalendar.currentCalendar()
    }
    
    func isAuthorized() -> Bool {
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent)

        return status == .Authorized
    }

    func authorize(completion: ((status: CalendarAuthorizationStatus) -> Void)?) {
        if isAuthorized() {
            fetchEvents()
            completion?(status: .Success)
            return
        }
        
        self.eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: { [weak self] (granted, error) -> Void in
            if granted {
                self?.fetchEvents()
                completion?(status: .Success)
                return
            } else {
                completion?(status: .Error)
            }
        })
    }

    private func fetchEvents() {
        let date         = 4.days.ago
        let calStartDate = date.beginningOfDay
        let calEndDate   = calStartDate + 1.day
        let predicate = self.eventStore.predicateForEventsWithStartDate(calStartDate, endDate: calEndDate, calendars: nil)

        var currentDateOffset = calStartDate

        if let matchingEvents = self.eventStore.eventsMatchingPredicate(predicate) {
            for event in matchingEvents {
                if let startDate = event.startDate, endDate = event.endDate {
                    if startDate < currentDateOffset {
                        continue
                    } else if startDate >= calEndDate {
                        break
                    }

                    if currentDateOffset < startDate {
                        self.events.append(Event.createEmptyEvent(startDate: currentDateOffset, endDate: startDate))
                    }

                    let event = Event.fromEKEvent(event as! EKEvent)

                    if endDate > calEndDate {
                        event.endDate = calEndDate
                    }

                    self.events.append(event)

                    currentDateOffset = endDate
                }
            }
        }

        if currentDateOffset < calEndDate {
            self.events.append(Event.createEmptyEvent(startDate: currentDateOffset, endDate: calEndDate))
        }
    }

}