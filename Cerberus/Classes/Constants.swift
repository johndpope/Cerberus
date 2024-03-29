import Foundation

let WrapperTop: CGFloat = 16
let WrapperBottom: CGFloat = 16

let TimelineHeight: CGFloat = 100
let EventPadding: CGFloat = 5
let EventInterval: CGFloat = EventPadding * 2

enum NotifictionNames : String {
    case CalendarModelDidChangeEventNotification                       = "CalendarModelDidChangeEventNotification"
    case CalendarModelDidChooseCalendarNotification                    = "CalendarModelDidChooseCalendarNotification"
    case TimelineCollectionViewControllerDidUpdateTimelineNotification = "TimelineCollectionViewControllerDidUpdateTimelineNotification"
}