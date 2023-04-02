//
//  DetailMovieViewController.swift
//  BoxOffice
//
//  Created by Rhode, Rilla on 2023/03/31.
//

import UIKit

final class DetailMovieViewController: UIViewController {
    private let server = NetworkManager()
    private let urlMaker = URLRequestMaker()
    private var movieCode: String
    private var movieInformation: MovieInformation?
    private var moviePoster: MoviePoster?
    
    private let scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollview
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let imageView = UIImageView()
    
    init(movieCode: String) {
        self.movieCode = movieCode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMainView()
        configureScrollView()
        configureStackView()
        configureImageView()
        configureContentStackView()
        
        fetchData()
    }
    
    private func fetchData() {
        fetchMovieInformationData(movieCode: movieCode) {
            guard let movieName = self.movieInformation?.movieName else { return }
            self.fetchMoviePosterData(movieName: movieName) {
                self.fetchPosterImageData { image in
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
    private func configureImageView() {
        contentStackView.addArrangedSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.6)
            ])
    }
    
    private func configureMainView() {
        view.backgroundColor = .white
        title = movieInformation?.movieName
    }
    
    private func fetchMovieInformationData(movieCode: String, completion: @escaping () -> Void) {
        guard let request = urlMaker.makeMovieInformationURLRequest(movieCode: movieCode) else { return }
        
        server.startLoad(request: request, mime: "json") { result in
            let decoder = DecodeManager()
            do {
                guard let verifiedFetchingResult = try self.verifyResult(result: result) else { return }
                let decodedFile = decoder.decodeJSON(data: verifiedFetchingResult, type: DetailMovieInformation.self)
                let verifiedDecodingResult = try self.verifyResult(result: decodedFile)
                
                self.movieInformation = verifiedDecodingResult?.movieInformationResult.movieInformation
                completion()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchMoviePosterData(movieName: String, completionHandler: @escaping () -> Void) {
        guard let posterRequest = urlMaker.makeMoviePosterURLRequest(movieName: movieName) else { return }
        server.startLoad(request: posterRequest, mime: "json") { result in
            let decoder = DecodeManager()
            do {
                guard let verifiedFetchingResult = try self.verifyResult(result: result) else { return }
                let decodedFile = decoder.decodeJSON(data: verifiedFetchingResult, type: MoviePoster.self)
                let verifiedDecodingResult = try self.verifyResult(result: decodedFile)
                
                self.moviePoster = verifiedDecodingResult
                completionHandler()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchPosterImageData(completionHandler: @escaping (UIImage?) -> Void) {
        guard let urlString = moviePoster?.documents[0].imageURL,
              let url = URL(string: urlString)  else { return }
        let request = URLRequest(url: url)
        server.startLoad(request: request, mime: "image") { result in
            do {
                guard let verifiedFetchingResult = try self.verifyResult(result: result) else { return }
                let image = UIImage(data: verifiedFetchingResult)
                completionHandler(image)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func verifyResult<T, E: Error>(result: Result<T, E>) throws -> T? {
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    private func configureScrollView() {
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func configureContentStackView() {
        let directorStackView = makeInfoStackView(title: "감독", context: "a")
        let productYearStackView = makeInfoStackView(title: "제작년도", context: "a")
        let openDateStackView = makeInfoStackView(title: "개봉일", context: "a")
        let showTimeStackView = makeInfoStackView(title: "상영시간", context: "a")
        let productStatusNameStackView = makeInfoStackView(title: "관람등급", context: "a")
        let nationStackView = makeInfoStackView(title: "제작국가", context: "a")
        let genresStackView = makeInfoStackView(title: "장르", context: "a")
        let actorsStackView = makeInfoStackView(title: "배우", context: "fjdlskfjldskfjldskjfldskjfldskfjldskjfldsjfldskfjdlskfjdlskfjldskfjdlskfjdlsafjdlsfkjdslfkjdaslkfjdslkfjdlafkjdaslfkjdaslfkajdlfdkjfldskajfldsakjfldaskjfads")

        contentStackView.addArrangedSubview(directorStackView)
        contentStackView.addArrangedSubview(productYearStackView)
        contentStackView.addArrangedSubview(openDateStackView)
        contentStackView.addArrangedSubview(showTimeStackView)
        contentStackView.addArrangedSubview(productStatusNameStackView)
        contentStackView.addArrangedSubview(nationStackView)
        contentStackView.addArrangedSubview(genresStackView)
        contentStackView.addArrangedSubview(actorsStackView)
    }
    
    private func configureStackView() {
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
        ])
    }
    
    private func makeInfoStackView(title: String, context: String?) -> UIStackView  {
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = title
            label.font = .boldSystemFont(ofSize: 17)
            label.textAlignment = .center
            
            return label
        }()
        
        let contextLabel: UILabel = {
            let label = UILabel()
            label.text = context
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .left
            label.numberOfLines = 0
            
            return label
        }()
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [titleLabel, contextLabel])
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.spacing = 8
            
            return stackView
        }()
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.17)
        ])
        
        return stackView
    }
}
