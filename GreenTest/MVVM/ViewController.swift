//
//  ViewController.swift
//  GreenTest
//
//  Created by djm on 2024/3/6.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

/*
 Section I - Brain Teasers (10%)
 Given an array of meeting time intervals consisting of start and end times [[s1,e1],[s2,e2],...] (si < ei), please provide a function with implementation by Swift/Kotlin to determine if a person could attend all meetings.
 For example,
 Input: intervals = [[0,30], [5,10], [15,20]] Output: false
 Explanation: The person can only attend some meetings because there is an overlap between [0,30] and [5,10], and between [0,30] and [15,20].
 Input: intervals = [[7,10], [2,4]] Output: true
 Explanation: The person can attend all meetings because there is no overlap between [7,10] and [2,4].
 Input: intervals = [[1,5], [8,9], [8,10]] Output: false
 Explanation: The person can only attend some meetings because there is an overlap between [8,9] and [8,10].
 */
func brainTeasers(_ array: [[Int]]) -> Bool {
    for i in 0..<array.count {
        let currentArray = array[i]
        for j in (i + 1)..<array.count {
            let nextArray = array[j]
            guard let currentFirstInt = currentArray.first,
                    let currentLastInt = currentArray.last,
                    let nextFirstInt = nextArray.first,
                    let nextLastInt = nextArray.last
            else {
                return false
            }
            if (currentFirstInt...currentLastInt).overlaps(nextFirstInt...nextLastInt) {
                return false
            }
        }
    }
    return true
}

/*
 Section II - Write an application (90%)
 
 1.Story
 AC1:Get song data from iTunes API
    * Implement a network request function that fetches song data from the iTunes API.
    * Parse the API response to extract relevant information such as artist name, track name, price, rating, and release date.
    * Ensure error handling is in place to handle any errors that occur during the API request and display appropriate error messages to the user.
    * API as follows: https://itunes.apple.com/search?term=歌&limit=200&country=HK
 
 AC2:Search data before the list as follows
    * Search by local response field artistName and trackName.

 AC3:Create two toggles on the top in the horizontal layout
    * Named the second toggle button as: Sort by Price.
    * Design and implement a toggle switch UI component on the top.
    * Enable users to toggle sorting functionality on or off using the switch.
 
 AC4:Create a vertical list view under the toggle
    * Follow the screen to implement a vertical list view UI component below the toggle.
    * Display the song items in a scrollable list view format.
 
 AC5:Sorting by toggle on/off and sort by trackPrice
    * Implement sorting functionality based on the toggle switch status.
    * When enabled, first sort song items by track price in ascending order and then by artist name in ascending order.
    * Update the list view to display the sorted items in the appropriate order.

 2.Architecture: MVVM
 
 3.Need to use Combine / RxSwift（iOS） or LiveData / Flow / RxKotlin（Android）
 
 4.Refer below to create the expected UI（next page）
 */

class ViewController: UIViewController {
    @IBOutlet weak var searchBackgroundView: UIView!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var optionBackgroundView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var viewModel: ViewControllerViewModel = {
        let vm = ViewControllerViewModel()
        vm.viewController = self
        return vm
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        setupReactive()
        
        viewModel.getiTunesApiData()
    }
    
    func setupUI() {
        searchBackgroundView.layer.cornerRadius = 8
        optionBackgroundView.layer.cornerRadius = 8
    }
    
    func setupReactive() {
        searchTextfield.rx.text.orEmpty.changed
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.viewModel.search(text)
            })
            .disposed(by: disposeBag)
        
        cancelBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.searchTextfield.isFirstResponder {
                    self.searchTextfield.resignFirstResponder()
                }
                self.searchTextfield.text = ""
                self.viewModel.search("")
            })
            .disposed(by: disposeBag)
        
        segmentedControl.rx.selectedSegmentIndex
            .bind(to: viewModel.rx.dataArrSorted)
            .disposed(by: disposeBag)
        
        let hud = createHUD()
        
        viewModel.data
            .catch({ [weak self] error  in
                hud.removeFromSuperview()
                self?.show(tips: "网络发生错误，请重试")
                return Observable.of([])
            })
            .bind(to: tableView.rx.items(cellIdentifier: "TableViewCell")) { index, model, cell in
                hud.removeFromSuperview()
                guard let cell = cell as? TableViewCell else { return }
                cell.setData(with: model)
            }
            .disposed(by: disposeBag)
    }
}

extension ViewController {
    private func createHUD(_ text: String = "正在加载") -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = text
        return hud
    }
    
    func show(tips: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = tips
        hud.hide(animated: true, afterDelay: 1)
    }
}
