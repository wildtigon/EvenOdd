//
//  WikipediaSearchCell.swift
//  EvenOdd
//
//  Created by Nguyễn Tiến Đạt on 3/29/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

public class WikipediaSearchCell: UITableViewCell {

    @IBOutlet var titleOutlet: UILabel!
    @IBOutlet var URLOutlet: UILabel!
    @IBOutlet var imagesOutlet: UICollectionView!

    var disposeBag: DisposeBag?

    let imageService = DefaultImageService.sharedImageService

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.imagesOutlet.registerNib(UINib(nibName: "WikipediaImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }

    var viewModel: SearchResultViewModel! {
        // didset, willset ... same meaning with set/get
        didSet {
            let disposeBag = DisposeBag()

            (viewModel?.title ?? Driver.just(""))
                .drive(self.titleOutlet.rx_text)
                .addDisposableTo(disposeBag)

            self.URLOutlet.text = viewModel.searchResult.URL.absoluteString ?? ""

            viewModel.imageURLs
                .drive(self.imagesOutlet.rx_itemsWithCellIdentifier("ImageCell", cellType: CollectionViewImageCell.self)) { [weak self] (_, URL, cell) in
                    cell.downloadableImage = self?.imageService.imageFromURL(URL) ?? Observable.empty()
                }
                .addDisposableTo(disposeBag)

            self.disposeBag = disposeBag
        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = nil
    }

    deinit {
    }

}
