import UIKit

class RootViewController: UIPageViewController, UIPageViewControllerDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        setViewControllers([dummyViewController()], direction: .Forward, animated: false, completion: nil)
    }

    // MARK: - Private

    private func dummyViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor(white: CGFloat(arc4random_uniform(100)) / 100.0, alpha: 1)
        return viewController
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return dummyViewController()
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return dummyViewController()
    }
}
