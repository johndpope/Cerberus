import UIKit
import EventKit
import EventKitUI

class MainViewController: UIViewController, EKCalendarChooserDelegate {

    weak var timelineCollectionViewController: TimelineCollectionViewController?
    weak var eventsCollectionViewController: EventsCollectionViewController?
    var calendarChooser: EKCalendarChooser!

    private var kvoContextForTimelineCollectionViewController = "kvoContextForTimelineCollectionViewController"
    private var kvoContextForEventsCollectionViewController = "kvoContextForEventsCollectionViewController"

    private let contentOffsetKeyPath = "contentOffset"

    deinit {
        self.timelineCollectionViewController?.removeObserver(self, forKeyPath: contentOffsetKeyPath)
        self.eventsCollectionViewController?.removeObserver(self, forKeyPath: contentOffsetKeyPath)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.destinationViewController {
        case let timelineCollectionViewController as TimelineCollectionViewController:
            self.timelineCollectionViewController = timelineCollectionViewController
            self.timelineCollectionViewController?.collectionView?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .New, context: &kvoContextForTimelineCollectionViewController)
        case let eventsCollectionViewController as EventsCollectionViewController:
            self.eventsCollectionViewController = eventsCollectionViewController
            self.eventsCollectionViewController?.collectionView?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .New, context: &kvoContextForEventsCollectionViewController)
        default:
            break
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let navCtrl = self.navigationController {
            let bgImage = UIImage(named: "background")
            navCtrl.navigationBar.setBackgroundImage(bgImage, forBarMetrics: UIBarMetrics.Default)
        }
        setNavbarTitle()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if self.calendarChooser == nil {
            presentCalendarChooser()
        }
    }

    func setNavbarTitle(date: NSDate = NSDate()) {
        self.title = date.stringFromFormat("EEEE, MMMM d, yyyy")
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 24.0)!
        ]
    }

    func presentCalendarChooser() {
        self.calendarChooser = EKCalendarChooser(
            selectionStyle: EKCalendarChooserSelectionStyleSingle,
            displayStyle:   EKCalendarChooserDisplayAllCalendars,
            entityType:     EKEntityTypeEvent,
            eventStore:     EKEventStore()
        )
        self.calendarChooser.delegate = self

        let navigationController = UINavigationController(rootViewController: self.calendarChooser)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }

    func calendarChooserSelectionDidChange(calendarChooser: EKCalendarChooser!) {
        var calendars: [EKCalendar] = []

        if let selectedCalendarsSet = calendarChooser.selectedCalendars as? Set<EKCalendar> {
            calendars = Array(selectedCalendarsSet)
        }

        NSNotificationCenter.defaultCenter().postNotificationName(NotifictionNames.CalendarModelDidChooseCalendarNotification.rawValue, object: calendars)

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Key Value Observing
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        var anotherCollectionViewController: UICollectionViewController?

        switch context {
        case &kvoContextForEventsCollectionViewController:
            anotherCollectionViewController = self.timelineCollectionViewController
        case &kvoContextForTimelineCollectionViewController:
            anotherCollectionViewController = self.eventsCollectionViewController
        default:
            return
        }

        if keyPath != contentOffsetKeyPath {
            return
        }

        if let anotherCollectionView = anotherCollectionViewController?.collectionView {
            if let point = change["new"] as? NSValue {
                let y = point.CGPointValue().y

                if anotherCollectionView.contentOffset.y != y {
                    anotherCollectionView.contentOffset.y = y
                }
            }
        }
    }
}