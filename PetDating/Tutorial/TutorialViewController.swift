import UIKit

struct Tutorial {
    let image: String
    let title: String
}

class TutorialViewController: UIViewController {
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    private var dataSource = [Tutorial]()
    private var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        dataSource = [
            Tutorial(image: "tutorial00", title: "Find your pet a friend or a companion."),
            Tutorial(image: "tutorial000", title: "Get to know your pet's fan.")
        ]
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Đăng ký custom collection view cell
        collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemCollectionViewCell")
        collectionView.backgroundColor = .white
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            
            flowLayout.estimatedItemSize = .zero
            flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            flowLayout.scrollDirection = .horizontal
        }
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    //Hàm chuyển màn sang register và login
    private func routeToAuthNavigation() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let navigation = UINavigationController(rootViewController: loginVC)
        navigation.modalPresentationStyle = .fullScreen
        self.present(navigation, animated: true)
        UserDefaults.standard.set(true, forKey: "tutorialCompleted")
    }
}

//MARK: - UICollectionViewDataSource:
extension TutorialViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
        let tutorialModel = dataSource[indexPath.row]
        
        cell.bindData(index: indexPath.row,
                      image: tutorialModel.image,
                      title: tutorialModel.title) { [weak self] in
            guard let self = self else {return}
            if indexPath.row + 1 == self.dataSource.count {
                self.routeToAuthNavigation()
                UserDefaults.standard.set(true, forKey: "tutorialCompleted")
            } else {
                self.currentPage = indexPath.row + 1
                self.collectionView.isPagingEnabled = false
                self.collectionView.scrollToItem(at: IndexPath(row: self.currentPage, section: 0), at: .centeredHorizontally, animated: true)
                self.collectionView.isPagingEnabled = true
            }
        }
        let attributedString = NSMutableAttributedString(string: tutorialModel.title)
        let range = (tutorialModel.title as NSString).range(of: "friend")
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemPink, range: range)
        cell.titleLbl.attributedText = attributedString
        return cell
    }
}

//MARK: - UICollectionViewDelegate:
extension TutorialViewController: UICollectionViewDelegate {
    
}
