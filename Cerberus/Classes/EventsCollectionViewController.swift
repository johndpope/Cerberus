import UIKit
import EventKit
import Async
import Timepiece

class EventsCollectionViewController: UICollectionViewController {

    var calendar: Calendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar = Calendar()

        self.calendar.authorize { status in
            switch status {
            case .Error:
                Async.background {
                    let alert = UIAlertController(
                        title: "許可されませんでした",
                        message: "Privacy->App->Reminderで変更してください",
                        preferredStyle: UIAlertControllerStyle.Alert
                    )

                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)

                    alert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }

            case .Success:
                println("Authorized")
            }
        }

        let nib = UINib(nibName: XibNames.EventCollectionViewCell.rawValue, bundle: nil)
        self.collectionView?.registerNib(nib, forCellWithReuseIdentifier: CollectionViewCellreuseIdentifier.EventCell.rawValue)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventStoreChanged:", name: EKEventStoreChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didChooseCalendarNotification:", name: NotifictionNames.MainViewControllerDidChooseCalendarNotification.rawValue, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: Update calendar events

    func updateCalendarEvents() {
        self.calendar?.update()
        self.collectionView?.reloadData()
    }

    func eventStoreChanged(notification: NSNotification) {
        updateCalendarEvents()
    }

    func didChooseCalendarNotification(notification: NSNotification) {
        updateCalendarEvents()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.calendar.events.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellreuseIdentifier.EventCell.rawValue, forIndexPath: indexPath) as! EventCollectionViewCell
        cell.eventModel = self.calendar.events[indexPath.row]
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let eventsCollectionViewFlowLayout = collectionViewLayout as! EventsCollectionViewFlowLayout
        let event = self.calendar.events[indexPath.row]
        return eventsCollectionViewFlowLayout.sizeForEvent(event)
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        var visibleIndexPaths = self.collectionView!.indexPathsForVisibleItems()

        let collectionViewHeight = self.collectionView!.bounds.height
        let collectionViewY = self.collectionView!.frame.origin.y

        var nearestCenter: (cell: UICollectionViewCell?, deviation: CGFloat) = (nil, CGFloat.infinity)

        for indexPath in visibleIndexPaths {
            let cell = self.collectionView!.cellForItemAtIndexPath(indexPath as! NSIndexPath)!
            let cellRect = self.collectionView!.convertRect(cell.frame, toView: self.collectionView?.superview)

            var y = cellRect.origin.y
            var height = cellRect.height

            if y < collectionViewY {
                height -= collectionViewY - y
                y = 0
            }

            var centerY = y + height / 2

            let deviation = centerY / collectionViewHeight - 0.5

            if abs(nearestCenter.deviation) > abs(deviation) {
                nearestCenter.deviation = deviation
                nearestCenter.cell = cell
            }
        }

        for indexPath in visibleIndexPaths {
            let cell = self.collectionView!.cellForItemAtIndexPath(indexPath as! NSIndexPath)!
            cell.hidden = false

            let cellRect  = self.collectionView!.convertRect(cell.frame, toView: self.collectionView?.superview)
            let y = cellRect.origin.y + cellRect.height / 2
            let deviation = y / collectionViewHeight - 0.5

            if cell == nearestCenter.cell {
                cell.transform = CGAffineTransformMakeScale(1.5, 1.5)
            } else {
                cell.transform = CGAffineTransformMakeScale(1, 1)
            }

            UIView.animateWithDuration(0.3, animations: { () -> Void in
                println(nearestCenter.deviation - y)
                //cell.transform = CGAffineTransformMakeTranslation(0, 100 * (deviation - nearestCenter.deviation))
            })
        }
    }
}
