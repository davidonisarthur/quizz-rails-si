# PrimoQuiz — Guia completo para continuação do desenvolvimento

> Este documento foi gerado para ser lido pelo Gemini CLI e contém todo o contexto necessário para continuar o desenvolvimento do PrimoQuiz sem perda de informação.

---

## Visão geral do projeto

PrimoQuiz é um web app de quiz interativo focado em **acessibilidade para o ensino de matemática para alunos surdos**. O conteúdo central é **teoria dos números** — especificamente números primos — com o objetivo de engajar alunos do ensino médio mostrando que o tema é relevante e fascinante (criptografia, WhatsApp, segurança bancária).

É um projeto de **Iniciação Científica** com parte prática em Ruby on Rails.

---

## Stack e ambiente

| Ferramenta | Versão |
|---|---|
| Ruby | 4.0.5 |
| Rails | 8.1.3 |
| Node | v26.2.0 |
| Banco (dev/test/prod) | PostgreSQL |
| CSS | Tailwind CSS (via `tailwindcss-rails` gem) |
| JS | Hotwire (Turbo + Stimulus) — já incluso no Rails 8 |
| Testes | RSpec + FactoryBot + Capybara + Selenium |
| Deploy | Render.com (gratuito) |

---

## Funcionalidades do MVP

- [x] Setup do projeto Rails com PostgreSQL e Tailwind
- [x] Database schema (migrations e models)
- [ ] Seeds com questões reais de teoria dos números
- [ ] Controllers e views do quiz
- [ ] Interatividade com Turbo Frames (sem reload de página)
- [ ] Cadastro, login e logout (`has_secure_password`)
- [ ] Salvar resultados e histórico do aluno
- [ ] Ranking global entre alunos
- [ ] I18n PT-BR / EN
- [ ] Modo LIBRAS (player de vídeo YouTube por questão)
- [ ] Tema claro / escuro (Tailwind dark mode via classe)
- [ ] Animações de feedback (acerto/erro)
- [ ] Deploy no Render.com

---

## Git Flow

```
main        → produção, só recebe merge de develop quando uma versão está pronta
develop     → integração, toda feature passa por aqui
feature/*   → uma branch por task, nasce de develop, merge via PR
fix/*       → correções pontuais, nasce de develop
```

**Fluxo de uma feature:**
```bash
git checkout develop && git pull origin develop
git checkout -b feature/nome-da-feature
# ... desenvolve ...
git add . && git commit -m "feat: descrição"
git push -u origin feature/nome-da-feature
# Abre PR no GitHub: feature/X → develop
# Após merge:
git checkout develop && git pull origin develop
git branch -d feature/nome-da-feature
git push origin --delete feature/nome-da-feature
```

**Convenção de commits (Conventional Commits):**
- `feat:` — nova funcionalidade
- `fix:` — correção de bug
- `chore:` — configuração, infra, dependências
- `test:` — adição ou correção de testes
- `docs:` — documentação

---

## Branches já mergeadas em develop

- `feature/setup-inicial` — app Rails criado, RSpec instalado, gems de teste configuradas
- `feature/setup-postgresql` — banco trocado de SQLite para PostgreSQL

---

## Próxima branch a criar

```bash
git checkout -b feature/database-schema
```

---

## Database schema

### Diagrama de relacionamentos

```
QuizModule (1) ──< Question (N) ──< Option (N)
                                └──< Feedback (N)
QuizModule (1) ──< QuizAttempt (N) >── User (1)
```

### Generators para rodar (nesta ordem)

```bash
rails g model QuizModule title_pt title_en slug:string:uniq unlocked:boolean

rails g model Question quiz_module:references body_pt:text body_en:text context_pt:text context_en:text correct_index:integer libras_video_url:string

rails g model Option question:references text_pt:string text_en:string

rails g model Feedback question:references kind:string body_pt:text body_en:text

rails g model User name:string email:string:uniq password_digest:string

rails g model QuizAttempt user:references quiz_module:references score:integer

rails db:migrate
```

### Models completos

**`app/models/quiz_module.rb`**
```ruby
class QuizModule < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy

  validates :title_pt, presence: true
  validates :title_en, presence: true
  validates :slug, presence: true, uniqueness: true
end
```

**`app/models/user.rb`**
```ruby
class User < ApplicationRecord
  has_secure_password

  has_many :quiz_attempts, dependent: :destroy
  has_many :quiz_modules, through: :quiz_attempts

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
end
```

**`app/models/question.rb`**
```ruby
class Question < ApplicationRecord
  belongs_to :quiz_module
  has_many :options, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  validates :body_pt, presence: true
  validates :correct_index, presence: true, inclusion: { in: 0..3 }
end
```

**`app/models/option.rb`**
```ruby
class Option < ApplicationRecord
  belongs_to :question

  validates :text_pt, presence: true
end
```

**`app/models/feedback.rb`**
```ruby
class Feedback < ApplicationRecord
  belongs_to :question

  validates :kind, presence: true, inclusion: { in: %w[correct incorrect] }
  validates :body_pt, presence: true
end
```

**`app/models/quiz_attempt.rb`**
```ruby
class QuizAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :quiz_module

  validates :score, numericality: { greater_than_or_equal_to: 0 }
end
```

---

## Testes (RSpec) — mínimo por feature

### Regras do projeto

- Commit `test:` fica na **mesma branch** da feature — o PR já chega com testes
- Não testar o que o Rails já garante (`belongs_to`, `validates presence` trivial)
- Pirâmide: maioria model specs (rápidos) → alguns request specs → poucos system specs (lentos, só para fluxos com Turbo/JS)
- Antes de abrir PR: `bundle exec rspec` deve passar

### Gems de teste já instaladas

```ruby
group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
```

### Testes da feature `database-schema`

**`spec/models/question_spec.rb`**
```ruby
require 'rails_helper'

RSpec.describe Question, type: :model do
  it "é inválida sem body_pt" do
    question = build(:question, body_pt: nil)
    expect(question).not_to be_valid
  end

  it "é inválida sem correct_index" do
    question = build(:question, correct_index: nil)
    expect(question).not_to be_valid
  end

  it "é inválida se correct_index estiver fora de 0..3" do
    question = build(:question, correct_index: 5)
    expect(question).not_to be_valid
  end

  it "é válida com todos os campos obrigatórios" do
    question = build(:question)
    expect(question).to be_valid
  end
end
```

**`spec/models/user_spec.rb`**
```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  it "é inválido sem email" do
    user = build(:user, email: nil)
    expect(user).not_to be_valid
  end

  it "não aceita email duplicado" do
    create(:user, email: "teste@email.com")
    user = build(:user, email: "teste@email.com")
    expect(user).not_to be_valid
  end

  it "authenticate retorna false com senha errada" do
    user = create(:user, password: "senha123")
    expect(user.authenticate("errada")).to be_falsey
  end

  it "authenticate retorna o user com senha correta" do
    user = create(:user, password: "senha123")
    expect(user.authenticate("senha123")).to eq(user)
  end
end
```

**`spec/models/quiz_attempt_spec.rb`**
```ruby
require 'rails_helper'

RSpec.describe QuizAttempt, type: :model do
  it "é inválido com score negativo" do
    attempt = build(:quiz_attempt, score: -1)
    expect(attempt).not_to be_valid
  end

  it "é válido com score zero" do
    attempt = build(:quiz_attempt, score: 0)
    expect(attempt).to be_valid
  end
end
```

### Factories (criar em `spec/factories/`)

**`spec/factories/quiz_modules.rb`**
```ruby
FactoryBot.define do
  factory :quiz_module do
    title_pt { "O que é primo?" }
    title_en { "What is a prime?" }
    sequence(:slug) { |n| "modulo-#{n}" }
    unlocked { true }
  end
end
```

**`spec/factories/questions.rb`**
```ruby
FactoryBot.define do
  factory :question do
    association :quiz_module
    body_pt { "Qual destes números é primo?" }
    body_en { "Which of these numbers is prime?" }
    context_pt { "Um número primo tem exatamente 2 divisores." }
    context_en { "A prime number has exactly 2 divisors." }
    correct_index { 1 }
    libras_video_url { "https://youtube.com/watch?v=exemplo" }
  end
end
```

**`spec/factories/options.rb`**
```ruby
FactoryBot.define do
  factory :option do
    association :question
    text_pt { "15" }
    text_en { "15" }
  end
end
```

**`spec/factories/feedbacks.rb`**
```ruby
FactoryBot.define do
  factory :feedback do
    association :question
    kind { "correct" }
    body_pt { "17 só divide por 1 e 17." }
    body_en { "17 divides only by 1 and 17." }
  end
end
```

**`spec/factories/users.rb`**
```ruby
FactoryBot.define do
  factory :user do
    name { "Arthur" }
    sequence(:email) { |n| "usuario#{n}@email.com" }
    password { "senha123" }
  end
end
```

**`spec/factories/quiz_attempts.rb`**
```ruby
FactoryBot.define do
  factory :quiz_attempt do
    association :user
    association :quiz_module
    score { 3 }
  end
end
```

---

## Seeds — `db/seeds.rb`

```ruby
puts "Criando módulos..."

modulo1 = QuizModule.find_or_create_by(slug: "o-que-e-primo") do |m|
  m.title_pt = "O que é primo?"
  m.title_en = "What is a prime?"
  m.unlocked = true
end

modulo2 = QuizModule.find_or_create_by(slug: "crivo-de-eratostenes") do |m|
  m.title_pt = "Crivo de Eratóstenes"
  m.title_en = "Sieve of Eratosthenes"
  m.unlocked = true
end

modulo3 = QuizModule.find_or_create_by(slug: "primos-e-criptografia") do |m|
  m.title_pt = "Primos e criptografia"
  m.title_en = "Primes and cryptography"
  m.unlocked = true
end

modulo4 = QuizModule.find_or_create_by(slug: "desafio-final") do |m|
  m.title_pt = "Desafio final"
  m.title_en = "Final challenge"
  m.unlocked = false
end

puts "Criando questões do Módulo 1..."

q1 = modulo1.questions.find_or_create_by(body_pt: "Qual destes números é primo?") do |q|
  q.body_en = "Which of these numbers is prime?"
  q.context_pt = "Um número primo tem exatamente 2 divisores: 1 e ele mesmo."
  q.context_en = "A prime number has exactly 2 divisors: 1 and itself."
  q.correct_index = 1
  q.libras_video_url = ""
end

q1.options.find_or_create_by(text_pt: "15") { |o| o.text_en = "15" }
q1.options.find_or_create_by(text_pt: "17") { |o| o.text_en = "17" }
q1.options.find_or_create_by(text_pt: "21") { |o| o.text_en = "21" }
q1.options.find_or_create_by(text_pt: "25") { |o| o.text_en = "25" }
q1.feedbacks.find_or_create_by(kind: "correct") do |f|
  f.body_pt = "17 só é divisível por 1 e por 17. Os outros: 15=3×5, 21=3×7, 25=5×5."
  f.body_en = "17 is only divisible by 1 and 17. Others: 15=3×5, 21=3×7, 25=5×5."
end
q1.feedbacks.find_or_create_by(kind: "incorrect") do |f|
  f.body_pt = "Era o 17. Os outros têm fatores: 15=3×5, 21=3×7, 25=5×5."
  f.body_en = "It was 17. The others have factors: 15=3×5, 21=3×7, 25=5×5."
end

q2 = modulo1.questions.find_or_create_by(body_pt: "O número 1 é primo?") do |q|
  q.body_en = "Is the number 1 prime?"
  q.context_pt = "Todo número primo precisa ter exatamente 2 divisores distintos."
  q.context_en = "Every prime must have exactly 2 distinct divisors."
  q.correct_index = 1
  q.libras_video_url = ""
end

q2.options.find_or_create_by(text_pt: "Sim, é primo") { |o| o.text_en = "Yes, it is prime" }
q2.options.find_or_create_by(text_pt: "Não, não é primo") { |o| o.text_en = "No, it is not prime" }
q2.options.find_or_create_by(text_pt: "Depende do contexto") { |o| o.text_en = "It depends" }
q2.options.find_or_create_by(text_pt: "Só em teoria") { |o| o.text_en = "Only in theory" }
q2.feedbacks.find_or_create_by(kind: "correct") do |f|
  f.body_pt = "1 tem só 1 divisor — falta um. Primos precisam de exatamente 2."
  f.body_en = "1 has only 1 divisor — missing one. Primes need exactly 2."
end
q2.feedbacks.find_or_create_by(kind: "incorrect") do |f|
  f.body_pt = "1 tem só 1 divisor (ele mesmo). Por isso não entra na definição de primo."
  f.body_en = "1 has only 1 divisor (itself). That's why it doesn't fit the definition of prime."
end

q3 = modulo1.questions.find_or_create_by(body_pt: "Quantos números primos existem?") do |q|
  q.body_en = "How many prime numbers are there?"
  q.context_pt = "Euclides demonstrou isso há mais de 2000 anos com uma prova de 3 linhas."
  q.context_en = "Euclid proved this over 2000 years ago with a 3-line proof."
  q.correct_index = 2
  q.libras_video_url = ""
end

q3.options.find_or_create_by(text_pt: "Exatamente 25") { |o| o.text_en = "Exactly 25" }
q3.options.find_or_create_by(text_pt: "Muitos, mas finitos") { |o| o.text_en = "Many but finite" }
q3.options.find_or_create_by(text_pt: "Infinitos") { |o| o.text_en = "Infinitely many" }
q3.options.find_or_create_by(text_pt: "Ninguém sabe") { |o| o.text_en = "Nobody knows" }
q3.feedbacks.find_or_create_by(kind: "correct") do |f|
  f.body_pt = "Euclides: suponha finitos, multiplique todos e some 1. O resultado cria um novo primo. Contradição."
  f.body_en = "Euclid: assume finite, multiply all and add 1. The result creates a new prime. Contradiction."
end
q3.feedbacks.find_or_create_by(kind: "incorrect") do |f|
  f.body_pt = "Há infinitos primos. Euclides provou: multiplique todos e some 1 — surge um novo primo."
  f.body_en = "There are infinitely many primes. Euclid proved: multiply all and add 1 — a new prime emerges."
end

puts "Criando questões do Módulo 2..."

q4 = modulo2.questions.find_or_create_by(body_pt: "Para que serve o Crivo de Eratóstenes?") do |q|
  q.body_en = "What is the Sieve of Eratosthenes for?"
  q.context_pt = "O algoritmo foi criado em ~240 a.C. e ainda é ensinado em ciência da computação."
  q.context_en = "Created in ~240 BC, still taught in computer science today."
  q.correct_index = 1
  q.libras_video_url = ""
end

q4.options.find_or_create_by(text_pt: "Peneirar grãos de trigo") { |o| o.text_en = "Filter wheat grains" }
q4.options.find_or_create_by(text_pt: "Encontrar todos os primos até N") { |o| o.text_en = "Find all primes up to N" }
q4.options.find_or_create_by(text_pt: "Calcular raízes quadradas") { |o| o.text_en = "Calculate square roots" }
q4.options.find_or_create_by(text_pt: "Resolver equações do 2º grau") { |o| o.text_en = "Solve quadratic equations" }
q4.feedbacks.find_or_create_by(kind: "correct") do |f|
  f.body_pt = "O crivo elimina múltiplos de cada primo sistematicamente, deixando só os primos."
  f.body_en = "The sieve systematically eliminates multiples of each prime, leaving only primes."
end
q4.feedbacks.find_or_create_by(kind: "incorrect") do |f|
  f.body_pt = "Ele encontra todos os primos até N eliminando múltiplos de cada primo."
  f.body_en = "It finds all primes up to N by eliminating multiples of each prime."
end

q5 = modulo2.questions.find_or_create_by(body_pt: "Para testar se N é primo, basta checar divisores até...") do |q|
  q.body_en = "To test if N is prime, you only need to check divisors up to..."
  q.context_pt = "Se N = a × b e a ≤ b, então a ≤ √N."
  q.context_en = "If N = a × b and a ≤ b, then a ≤ √N."
  q.correct_index = 1
  q.libras_video_url = ""
end

q5.options.find_or_create_by(text_pt: "N/2") { |o| o.text_en = "N/2" }
q5.options.find_or_create_by(text_pt: "√N") { |o| o.text_en = "√N" }
q5.options.find_or_create_by(text_pt: "N−1") { |o| o.text_en = "N−1" }
q5.options.find_or_create_by(text_pt: "log(N)") { |o| o.text_en = "log(N)" }
q5.feedbacks.find_or_create_by(kind: "correct") do |f|
  f.body_pt = "Se N tem fator maior que √N, o outro seria menor — já testado. Elegante."
  f.body_en = "If N has a factor > √N, the other would be < √N — already tested. Elegant."
end
q5.feedbacks.find_or_create_by(kind: "incorrect") do |f|
  f.body_pt = "É √N. Se há fator maior que √N, o outro seria menor — já teria sido testado."
  f.body_en = "It's √N. If there's a factor > √N, the other would be < √N — already tested."
end

puts "Criando questões do Módulo 3..."

q6 = modulo3.questions.find_or_create_by(body_pt: "O que protege a criptografia RSA?") do |q|
  q.body_en = "What protects RSA cryptography?"
  q.context_pt = "RSA está no HTTPS, apps bancários, WhatsApp..."
  q.context_en = "RSA is in HTTPS, banking apps, WhatsApp..."
  q.correct_index = 1
  q.libras_video_url = ""
end

q6.options.find_or_create_by(text_pt: "Somar números grandes") { |o| o.text_en = "Adding large numbers" }
q6.options.find_or_create_by(text_pt: "Fatorar N em primos é difícil") { |o| o.text_en = "Factoring N into primes is hard" }
q6.options.find_or_create_by(text_pt: "Calcular raízes cúbicas") { |o| o.text_en = "Calculating cube roots" }
q6.options.find_or_create_by(text_pt: "Resolver sistemas lineares") { |o| o.text_en = "Solving linear systems" }
q6.feedbacks.find_or_create_by(kind: "correct") do |f|
  f.body_pt = "Multiplicar dois primos grandes é rápido. Fatorar o produto leva bilhões de anos."
  f.body_en = "Multiplying two large primes is fast. Factoring the product takes billions of years."
end
q6.feedbacks.find_or_create_by(kind: "incorrect") do |f|
  f.body_pt = "A fatoração. Multiplicar dois primos é rápido; fatorar o produto levaria bilhões de anos."
  f.body_en = "Factorization. Multiplying primes is fast; factoring the product would take billions of years."
end

q7 = modulo3.questions.find_or_create_by(body_pt: "O Teorema Fundamental da Aritmética diz que...") do |q|
  q.body_en = "The Fundamental Theorem of Arithmetic states that..."
  q.context_pt = "Este teorema é a razão de chamarmos primos de 'átomos da matemática'."
  q.context_en = "This theorem is why primes are called the 'atoms of mathematics'."
  q.correct_index = 1
  q.libras_video_url = ""
end

q7.options.find_or_create_by(text_pt: "Todo primo é ímpar") { |o| o.text_en = "Every prime is odd" }
q7.options.find_or_create_by(text_pt: "Todo inteiro > 1 tem fatoração única em primos") { |o| o.text_en = "Every integer > 1 has a unique prime factorization" }
q7.options.find_or_create_by(text_pt: "Há infinitos primos gêmeos") { |o| o.text_en = "There are infinitely many twin primes" }
q7.options.find_or_create_by(text_pt: "Todo par é soma de dois primos") { |o| o.text_en = "Every even is a sum of two primes" }
q7.feedbacks.find_or_create_by(kind: "correct") do |f|
  f.body_pt = "12=2²×3, 100=2²×5². Uma e só uma fatoração por inteiro. São os tijolos de tudo."
  f.body_en = "12=2²×3, 100=2²×5². One and only one factorization per integer. The bricks of everything."
end
q7.feedbacks.find_or_create_by(kind: "incorrect") do |f|
  f.body_pt = "Todo inteiro >1 tem exatamente uma fatoração em primos: 12=2²×3, 100=2²×5²."
  f.body_en = "Every integer >1 has exactly one prime factorization: 12=2²×3, 100=2²×5²."
end

puts "Seeds criadas com sucesso!"
puts "  #{QuizModule.count} módulos"
puts "  #{Question.count} questões"
puts "  #{Option.count} opções"
puts "  #{Feedback.count} feedbacks"
```

---

## Rotas — `config/routes.rb`

```ruby
Rails.application.routes.draw do
  scope "/:locale", locale: /pt-BR|en/ do
    root "home#index"

    resources :quiz_modules, param: :slug, only: [:index] do
      member do
        get  :play,   to: "quiz#show"
        post :answer, to: "quiz#answer"
        get  :result, to: "quiz#result"
      end
    end

    resources :users, only: [:new, :create]
    resource  :session, only: [:new, :create, :destroy]
    get  "/profile", to: "users#profile", as: :profile
    get  "/ranking", to: "ranking#index",  as: :ranking
  end

  root "home#index", as: :root_redirect
end
```

---

## Controllers a criar

### `ApplicationController` — base

```ruby
class ApplicationController < ActionController::Base
  before_action :set_locale

  private

  def set_locale
    locale = params[:locale] || session[:locale] || "pt-BR"
    I18n.locale = locale if %w[pt-BR en].include?(locale)
    session[:locale] = I18n.locale
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def require_login
    redirect_to new_session_path(locale: I18n.locale) unless current_user
  end
end
```

### `QuizController`

```ruby
class QuizController < ApplicationController
  before_action :set_module

  def show
    session[:quiz] = { module_id: @module.id, question_index: 0, score: 0 }
    @question = @module.questions.order(:id).first
    @options  = @question.options.order(:id)
  end

  def answer
    quiz      = session[:quiz]
    questions = @module.questions.order(:id)
    @question = questions[quiz["question_index"]]
    chosen    = params[:option_index].to_i
    correct   = chosen == @question.correct_index
    session[:quiz]["score"] += 1 if correct
    @feedback = @question.feedbacks.find_by(kind: correct ? "correct" : "incorrect")
    @next_index = quiz["question_index"] + 1
    session[:quiz]["question_index"] = @next_index
    @next_question = questions[@next_index]
    @options = @question.options.order(:id)
    render :answer
  end

  def result
    score = session.dig(:quiz, "score") || 0
    total = @module.questions.count
    if current_user
      QuizAttempt.create(user: current_user, quiz_module: @module, score: score)
    end
    @score = score
    @total = total
    session.delete(:quiz)
  end

  private

  def set_module
    @module = QuizModule.find_by!(slug: params[:slug])
  end
end
```

### `SessionsController`

```ruby
class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path(locale: I18n.locale)
    else
      flash.now[:alert] = t("sessions.invalid")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path(locale: I18n.locale)
  end
end
```

### `UsersController`

```ruby
class UsersController < ApplicationController
  before_action :require_login, only: [:profile]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path(locale: I18n.locale)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def profile
    @attempts = current_user.quiz_attempts.includes(:quiz_module).order(created_at: :desc)
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
```

### `RankingController`

```ruby
class RankingController < ApplicationController
  before_action :require_login

  def index
    @ranking = User
      .joins(:quiz_attempts)
      .select("users.id, users.name, SUM(quiz_attempts.score) AS total_score")
      .group("users.id, users.name")
      .order("total_score DESC")
      .limit(20)
  end
end
```

---

## Design System

O app usa um design **dark-first** inspirado no Notion com os seguintes tokens:

```css
/* Dark (padrão) */
--bg0: #0e0e0f;
--bg1: #141415;
--bg2: #1c1c1e;
--bg3: #242426;
--tx0: #f0f0f0;
--tx1: #a8a8b0;
--tx2: #606068;
--accent: #a78bfa;          /* roxo — único acento */
--green: #34d399;           /* feedback correto */
--red: #f87171;             /* feedback incorreto */
--amber: #fbbf24;           /* LIBRAS / avisos */

/* Light */
--bg0: #fafaf8;
--bg2: #ffffff;
--tx0: #1a1a1a;
--accent: #6d50e8;
```

**Tema dark/light via Tailwind:**
- `tailwind.config.js`: `darkMode: 'class'`
- Toggle adiciona/remove classe `dark` no `<html>`
- Stimulus controller `theme_controller.js` persiste em `localStorage`
- Inline script no `<head>` aplica antes do render para evitar flash

**Tipografia:** Inter com `letter-spacing: -0.5px` em títulos grandes. Bordas de `0.5px` com opacidade baixa.

---

## I18n

**`config/locales/pt-BR.yml`** (exemplo)
```yaml
pt-BR:
  sessions:
    invalid: "Email ou senha incorretos"
  quiz:
    correct: "Correto!"
    incorrect: "Quase!"
    next_question: "Próxima questão"
    see_result: "Ver resultado"
  ranking:
    title: "Ranking"
    score: "Pontuação"
```

**`config/locales/en.yml`** (exemplo)
```yaml
en:
  sessions:
    invalid: "Invalid email or password"
  quiz:
    correct: "Correct!"
    incorrect: "Not quite!"
    next_question: "Next question"
    see_result: "See result"
  ranking:
    title: "Ranking"
    score: "Score"
```

---

## Modo LIBRAS

- Campo `libras_video_url` em cada `Question` contém URL do YouTube não-listado
- Toggle salvo em `session[:libras_mode]` via Stimulus controller
- Quando ativo, botão aparece em cada questão abrindo modal com `<iframe>` do YouTube
- Todos os botões têm `aria-label` e imagens têm `alt` para acessibilidade real

---

## Animações de gamificação

- Acerto: classe `animate-bounce` (Tailwind) no ícone de correto
- Erro: keyframe `shake` customizado no `tailwind.config.js`
- Barra de progresso: CSS `transition: width 0.5s ease`
- Stimulus controller escuta `turbo:frame-load` e aplica classes

**`tailwind.config.js`** — adicionar:
```js
theme: {
  extend: {
    keyframes: {
      shake: {
        '0%, 100%': { transform: 'translateX(0)' },
        '20%, 60%': { transform: 'translateX(-6px)' },
        '40%, 80%': { transform: 'translateX(6px)' },
      }
    },
    animation: {
      shake: 'shake 0.4s ease-in-out',
    }
  }
}
```

---

## Deploy no Render.com

**1. Adicionar ao `Gemfile`:**
```ruby
gem "pg"  # já deve estar para todos os ambientes
```

**2. Criar `render.yaml` na raiz:**
```yaml
services:
  - type: web
    name: primo-quiz
    env: ruby
    buildCommand: "./bin/render-build.sh"
    startCommand: "bundle exec rails server -p $PORT"
    envVars:
      - key: RAILS_MASTER_KEY
        sync: false
      - key: RAILS_ENV
        value: production
      - key: DATABASE_URL
        fromDatabase:
          name: primo-quiz-db
          property: connectionString

databases:
  - name: primo-quiz-db
    databaseName: primo_quiz_production
    user: primo_quiz
```

**3. Criar `bin/render-build.sh`:**
```bash
#!/usr/bin/env bash
set -o errexit
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
bundle exec rails db:seed
```

```bash
chmod +x bin/render-build.sh
```

**4. Deploy:**
- Merge de `develop` → `main` no GitHub
- Render detecta o push em `main` e faz deploy automático

---

## Ordem das próximas tasks (branches)

```
feature/database-schema       ← PRÓXIMA — generators, models, testes
feature/seeds-questoes        ← seeds com find_or_create_by
feature/quiz-controller-views ← controller, rotas, views estáticas
feature/quiz-turbo-interativo ← Turbo Frames, sem reload
feature/autenticacao          ← has_secure_password, login, logout
feature/historico-tentativas  ← salvar QuizAttempt, perfil do aluno
feature/i18n-pt-en            ← arquivos de locale, set_locale
feature/modo-libras           ← toggle, modal YouTube, aria-labels
feature/tema-claro-escuro     ← Tailwind darkMode class, Stimulus
feature/animacoes-feedback    ← bounce, shake, progress bar
feature/ranking               ← query agregada, Turbo Stream
feature/deploy-render         ← render.yaml, build script
```

---

## Observações importantes

- **`find_or_create_by` nas seeds** — idempotente, pode rodar `rails db:seed` várias vezes
- **`has_secure_password`** usa BCrypt automaticamente — nunca salva senha em texto puro
- **Turbo Frames** — envolver a questão em `<%= turbo_frame_tag "questao" %>` para atualização parcial sem reload
- **System specs** — usar somente para fluxos com Turbo/JS; são lentas (Capybara + Chrome headless)
- **`bundle exec rspec` deve passar antes de todo PR**
- **Não usar Devise** — `has_secure_password` é mais didático para um projeto de IC
- **Vídeos LIBRAS** — hospedar no YouTube como não-listado e embedar via `<iframe>`

---

*Documento gerado em junho de 2026. Projeto em desenvolvimento ativo.*
