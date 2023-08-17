import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!

    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        previewImage.layer.cornerRadius = 20
        
        self.presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(view: self)

        setLoadingIndicator(enabled: true)
    }

    // MARK: - Actions

    @IBAction private func noButtonPress(_ sender: Any) {
        presenter.noButtonPress()
    }

    @IBAction private func yesButtonPress(_ sender: Any) {
        presenter.yesButtonPress()
    }
    
    func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
        previewImage.layer.borderWidth = 0
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertData = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }

            self.presenter?.resetGame()
        }

        alertPresenter?.show(data: alertData)
    }

    
    func setButtons(enabled: Bool) {
        for button in buttons {
            button.isEnabled = enabled
        }
    }
    
    func setLoadingIndicator(enabled: Bool) {
        activityIndicator.isHidden = enabled
        if (enabled) {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
       
    }
    
    func hightlightImageBorder(isCorrect: Bool) {
        let borderColor = isCorrect
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor
        
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = borderColor
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
