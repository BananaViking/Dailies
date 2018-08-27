//
//  PageVC.swift
//  PageViewController
//
//  Created by Banana Viking on 8/8/18.
//  Copyright © 2018 Banana Viking. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // can change transition style from page curl to scroll in attributes inspector
    
    var pageControl = UIPageControl()
    
    lazy var viewControllerArray: [UIViewController] = {
       let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let onboard1ViewController = storyBoard.instantiateViewController(withIdentifier: "onboard1ViewController")
        let onboard2ViewController = storyBoard.instantiateViewController(withIdentifier: "onboard2ViewController")
        let onboard3ViewController = storyBoard.instantiateViewController(withIdentifier: "onboard3ViewController")
        let onboard4ViewController = storyBoard.instantiateViewController(withIdentifier: "onboard4ViewController")
        
        return [onboard1ViewController, onboard2ViewController, onboard3ViewController, onboard4ViewController]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let firstViewController = viewControllerArray.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        configurePageControl()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllerArray.index(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard viewControllerArray.count > previousIndex else { return nil }
        return viewControllerArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllerArray.index(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard viewControllerArray.count != nextIndex else { return nil }
        guard viewControllerArray.count > nextIndex else { return nil }
        return viewControllerArray[nextIndex]
    }
    
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 50,
                                                  width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = viewControllerArray.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .black
        pageControl.currentPageIndicatorTintColor = .white
        view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        pageControl.currentPage = viewControllerArray.index(of: pageContentViewController)!
    }
    
}
















