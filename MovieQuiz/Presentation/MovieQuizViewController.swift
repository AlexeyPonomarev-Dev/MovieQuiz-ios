import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?

    private let presenter = MovieQuizPresenter()
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        previewImage.layer.cornerRadius = 20
        
        self.statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter(view: self)
        presenter.viewController = self

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        setLoadingIndicator(enabled: true)
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        setLoadingIndicator(enabled: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func showNetworkError(message: String) {
        setLoadingIndicator(enabled: false)

        let alertData = AlertModel(
            title: "Ощибка",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            guard let self = self else { return }

            self.questionFactory?.loadData()
            self.setLoadingIndicator(enabled: true)
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
        }

        alertPresenter?.show(data: alertData)
    }
    
    

    // MARK: - Actions

    @IBAction private func noButtonPress(_ sender: Any) {
        presenter.noButtonPress()
    }

    @IBAction private func yesButtonPress(_ sender: Any) {
        presenter.yesButtonPress()
    }
    
    // MARK: - Private functions

    private func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertData = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }

            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }

        alertPresenter?.show(data: alertData)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if (isCorrect) {
            correctAnswers += 1
        }

        let borderColor = isCorrect
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor
        
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = borderColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.showNextQuestionOrResults()
            self.setButtons(enabled: true)
            self.previewImage.layer.borderWidth = 0
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQWuestion() {
            statisticService?.store(correct: correctAnswers, total: presenter.questionAmount)
        
            guard let record = statisticService?.bestGame,
                  let gamesCount = statisticService?.gamesCount,
                  let acuracy = statisticService?.totalAccuracy else {
                return
            }

            let message = "Ваш результат: \(correctAnswers)/\(presenter.questionAmount)\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(record.correct)/\(record.total) (\(record.date))\nСредняя точность: \(String(format: "%.2f", acuracy))%"
            
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть еще раз")
            
            show(quiz: result)
        } else {
            presenter.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    func setButtons(enabled: Bool) {
        for button in buttons {
            button.isEnabled = enabled
        }
    }
    
    private func setLoadingIndicator(enabled: Bool) {
        activityIndicator.isHidden = enabled
        if (enabled) {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
       
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
