


import UIKit

final class FlickrPhotosViewController: UICollectionViewController {
  
  // MARK: - Properties
  private let reuseIdentifier = "FlickrCell"
  //Массив который отслеживает все поиски
  private var searches: [FlickrSearchResults] = []
  //Создали объект flickr - экземпляр класса Flickr, теперь доступны все свойства и методы класса Flickr
  private let flickr = Flickr()
  private let itemsPerRow: CGFloat = 3
  
  private let sectionInsets = UIEdgeInsets(
    top: 50,
    left: 20,
    bottom: 50,
    right: 20)
  
}

//метод для получения конкретной фотографии

private extension FlickrPhotosViewController {
  func photo(for indexPath: IndexPath) -> FlickrPhoto {
    return searches[indexPath.section].searchResults[indexPath.row]
  }
}

// MARK: - Text Field Delegate
extension FlickrPhotosViewController: UITextFieldDelegate {
  //Метод делегата
  // Asks the delegate whether to process the pressing of the Return button for the text field.
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard
      let text = textField.text,
      !text.isEmpty
    else { return true }

// 1
//    After adding an activity view, you use the Flickr wrapper class to search Flickr asynchronously for photos that match the given search term. When the search completes, you call the completion block with the result set of FlickrPhoto objects and any errors.
    //Получаем фотографии с сервера согласно поискового запроса через функцию searchFlickr

    let activityIndicator = UIActivityIndicatorView(style: .medium)
    textField.addSubview(activityIndicator)
    //устанавливаем границы активити индикатору равные границам textField
    activityIndicator.frame = textField.bounds
    activityIndicator.startAnimating()

    flickr.searchFlickr(for: text) { searchResults in
      DispatchQueue.main.async {
        activityIndicator.removeFromSuperview()

        switch searchResults {
        case .failure(let error) :
        // 2 Выводим ошибки получение фото в консоль если они есть
          print("Error Searching: \(error)")
        // 3 Затем вы регистрируете результаты и добавляете их в начало массива поиска.
        case .success(let results):
          print("Found \(results.searchResults.count) matching \(results.searchTerm) ")
          //добавляем в наш массив результаты поиска под индексом 0
          self.searches.insert(results, at: 0)
        //4 Обновляем нашу таблицу
          self.collectionView?.reloadData()
        }
      }
    }

    textField.text = nil
    //убираем клавиатуру после окончания ввода текста в textField
    textField.resignFirstResponder()
    return true
 }
}

// Работа с CollectionView

// MARK: - UICollectionViewDataSource

extension FlickrPhotosViewController {
  // 1 There’s one search per section, so the number of sections is the count of searches.
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    searches.count
  }
  // 2 The number of items in a section is the count of searchResults from the relevant FlickrSearch.
    
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return searches[section].searchResults.count
  }
  // 3 This is a placeholder method to return a blank cell. You’ll populate it later. Note that collection views require you to register a cell with a reuse identifier. A runtime error will occur if you don’t.
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  // 1 The cell coming back is now a FlickrPhotoCell.
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrPhotoCell
  // 2 You need to get the FlickrPhoto representing the photo to display by using the convenience method from earlier.
    let flickrPhoto = photo(for: indexPath)
    cell.backgroundColor = .white
  // 3 You populate the image view with the thumbnail
    cell.imageView.image = flickrPhoto.thumbnail
    return cell
  }
}

// MARK: - Collection View Flow Layout Delegate

extension FlickrPhotosViewController: UICollectionViewDelegateFlowLayout {
  
  // 1 collectionView(_:layout:sizeForItemAt:) tells the layout the size of a given cell.
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
  // 2 Здесь вы определяете общий объем пространства, занимаемого заполнением. У вас будет n +1 пробелов одинакового размера, где n - количество элементов в строке. Вы можете взять размер пространства на левой врезке раздела. Вычтя это из ширины представления и разделив на количество элементов в строке, вы получите ширину для каждого элемента. Затем вы возвращаете размер в виде квадрата.
    
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availabWidth = view.frame.width - paddingSpace
    let widthPerItem = availabWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
//    return CGSize(width: 100, height: 500)
  }
  
  // 3 collectionView(_:layout:insetForSectionAt:) returns the spacing between the cells, headers and footers. A constant stores the value.
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  // 4 This method controls the spacing between each line in the layout. You want this spacing to match the padding at the left and right.
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}



