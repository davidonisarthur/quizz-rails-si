puts "Criando módulos..."

modulo1 = QuizModule.find_or_create_by!(slug: "o-que-e-primo") do |m|
  m.title_pt = "O que é primo?"
  m.title_en = "What is a prime?"
  m.unlocked = true
end

modulo2 = QuizModule.find_or_create_by!(slug: "crivo-de-eratostenes") do |m|
  m.title_pt = "Crivo de Eratóstenes"
  m.title_en = "Sieve of Eratosthenes"
  m.unlocked = true
end

modulo3 = QuizModule.find_or_create_by!(slug: "primos-e-criptografia") do |m|
  m.title_pt = "Primos e criptografia"
  m.title_en = "Primes and cryptography"
  m.unlocked = true
end

modulo4 = QuizModule.find_or_create_by!(slug: "desafio-final") do |m|
  m.title_pt = "Desafio final"
  m.title_en = "Final challenge"
  m.unlocked = false
end

puts "Criando questões do Módulo 1..."

q1 = modulo1.questions.find_or_create_by!(body_pt: "Qual destes números é primo?") do |q|
  q.body_en = "Which of these numbers is prime?"
  q.context_pt = "Um número primo tem exatamente 2 divisores: 1 e ele mesmo."
  q.context_en = "A prime number has exactly 2 divisors: 1 and itself."
  q.correct_index = 1
  q.libras_video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
end

q1.options.find_or_create_by!(text_pt: "15") { |o| o.text_en = "15" }
q1.options.find_or_create_by!(text_pt: "17") { |o| o.text_en = "17" }
q1.options.find_or_create_by!(text_pt: "21") { |o| o.text_en = "21" }
q1.options.find_or_create_by!(text_pt: "25") { |o| o.text_en = "25" }
q1.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "17 só é divisível por 1 e por 17. Os outros: 15=3×5, 21=3×7, 25=5×5."
  f.body_en = "17 is only divisible by 1 and 17. Others: 15=3×5, 21=3×7, 25=5×5."
end
q1.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Era o 17. Os outros têm fatores: 15=3×5, 21=3×7, 25=5×5."
  f.body_en = "It was 17. The others have factors: 15=3×5, 21=3×7, 25=5×5."
end

q2 = modulo1.questions.find_or_create_by!(body_pt: "O número 1 é primo?") do |q|
  q.body_en = "Is the number 1 prime?"
  q.context_pt = "Todo número primo precisa ter exatamente 2 divisores distintos."
  q.context_en = "Every prime must have exactly 2 distinct divisors."
  q.correct_index = 1
  q.libras_video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
end

q2.options.find_or_create_by!(text_pt: "Sim, é primo") { |o| o.text_en = "Yes, it is prime" }
q2.options.find_or_create_by!(text_pt: "Não, não é primo") { |o| o.text_en = "No, it is not prime" }
q2.options.find_or_create_by!(text_pt: "Depende do contexto") { |o| o.text_en = "It depends" }
q2.options.find_or_create_by!(text_pt: "Só em teoria") { |o| o.text_en = "Only in theory" }
q2.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "1 tem só 1 divisor — falta um. Primos precisam de exatamente 2."
  f.body_en = "1 has only 1 divisor — missing one. Primes need exactly 2."
end
q2.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "1 tem só 1 divisor (ele mesmo). Por isso não entra na definição de primo."
  f.body_en = "1 has only 1 divisor (itself). That's why it doesn't fit the definition of prime."
end

q3 = modulo1.questions.find_or_create_by!(body_pt: "Quantos números primos existem?") do |q|
  q.body_en = "How many prime numbers are there?"
  q.context_pt = "Euclides demonstrou isso há mais de 2000 anos com uma prova de 3 linhas."
  q.context_en = "Euclid proved this over 2000 years ago with a 3-line proof."
  q.correct_index = 2
  q.libras_video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
end

q3.options.find_or_create_by!(text_pt: "Exatamente 25") { |o| o.text_en = "Exactly 25" }
q3.options.find_or_create_by!(text_pt: "Muitos, mas finitos") { |o| o.text_en = "Many but finite" }
q3.options.find_or_create_by!(text_pt: "Infinitos") { |o| o.text_en = "Infinitely many" }
q3.options.find_or_create_by!(text_pt: "Ninguém sabe") { |o| o.text_en = "Nobody knows" }
q3.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Euclides: suponha finitos, multiplique todos e some 1. O resultado cria um novo primo. Contradição."
  f.body_en = "Euclid: assume finite, multiply all and add 1. The result creates a new prime. Contradiction."
end
q3.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Há infinitos primos. Euclides provou: multiplique todos e some 1 — surge um novo primo."
  f.body_en = "There are infinitely many primes. Euclid proved: multiply all and add 1 — a new prime emerges."
end

puts "Criando questões do Módulo 2..."

q4 = modulo2.questions.find_or_create_by!(body_pt: "Para que serve o Crivo de Eratóstenes?") do |q|
  q.body_en = "What is the Sieve of Eratosthenes for?"
  q.context_pt = "O algoritmo foi criado em ~240 a.C. e ainda é ensinado em ciência da computação."
  q.context_en = "Created in ~240 BC, still taught in computer science today."
  q.correct_index = 1
  q.libras_video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
end

q4.options.find_or_create_by!(text_pt: "Peneirar grãos de trigo") { |o| o.text_en = "Filter wheat grains" }
q4.options.find_or_create_by!(text_pt: "Encontrar todos os primos até N") { |o| o.text_en = "Find all primes up to N" }
q4.options.find_or_create_by!(text_pt: "Calcular raízes quadradas") { |o| o.text_en = "Calculate square roots" }
q4.options.find_or_create_by!(text_pt: "Resolver equações do 2º grau") { |o| o.text_en = "Solve quadratic equations" }
q4.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "O crivo elimina múltiplos de cada primo sistematicamente, deixando só os primos."
  f.body_en = "The sieve systematically eliminates multiples of each prime, leaving only primes."
end
q4.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Ele encontra todos os primos até N eliminando múltiplos de cada primo."
  f.body_en = "It finds all primes up to N by eliminating multiples of each prime."
end

q5 = modulo2.questions.find_or_create_by!(body_pt: "Para testar se N é primo, basta checar divisores até...") do |q|
  q.body_en = "To test if N is prime, you only need to check divisors up to..."
  q.context_pt = "Se N = a × b e a ≤ b, então a ≤ √N."
  q.context_en = "If N = a × b and a ≤ b, then a ≤ √N."
  q.correct_index = 1
  q.libras_video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
end

q5.options.find_or_create_by!(text_pt: "N/2") { |o| o.text_en = "N/2" }
q5.options.find_or_create_by!(text_pt: "√N") { |o| o.text_en = "√N" }
q5.options.find_or_create_by!(text_pt: "N−1") { |o| o.text_en = "N−1" }
q5.options.find_or_create_by!(text_pt: "log(N)") { |o| o.text_en = "log(N)" }
q5.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Se N tem fator maior que √N, o outro seria menor — já testado. Elegante."
  f.body_en = "If N has a factor > √N, the other would be < √N — already tested. Elegant."
end
q5.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "É √N. Se há fator maior que √N, o outro seria menor — já teria sido testado."
  f.body_en = "It's √N. If there's a factor > √N, the other would be < √N — already tested."
end

puts "Criando questões do Módulo 3..."

q6 = modulo3.questions.find_or_create_by!(body_pt: "O que protege a criptografia RSA?") do |q|
  q.body_en = "What protects RSA cryptography?"
  q.context_pt = "RSA está no HTTPS, apps bancários, WhatsApp..."
  q.context_en = "RSA is in HTTPS, banking apps, WhatsApp..."
  q.correct_index = 1
  q.libras_video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
end

q6.options.find_or_create_by!(text_pt: "Somar números grandes") { |o| o.text_en = "Adding large numbers" }
q6.options.find_or_create_by!(text_pt: "Fatorar N em primos é difícil") { |o| o.text_en = "Factoring N into primes is hard" }
q6.options.find_or_create_by!(text_pt: "Calcular raízes cúbicas") { |o| o.text_en = "Calculating cube roots" }
q6.options.find_or_create_by!(text_pt: "Resolver sistemas lineares") { |o| o.text_en = "Solving linear systems" }
q6.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Multiplicar dois primos grandes é rápido. Fatorar o produto leva bilhões de anos."
  f.body_en = "Multiplying two large primes is fast. Factoring the product takes billions of years."
end
q6.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "A fatoração. Multiplicar dois primos é rápido; fatorar o produto levaria bilhões de anos."
  f.body_en = "Factorization. Multiplying primes is fast; factoring the product would take billions of years."
end

q7 = modulo3.questions.find_or_create_by!(body_pt: "O Teorema Fundamental da Aritmética diz que...") do |q|
  q.body_en = "The Fundamental Theorem of Arithmetic states that..."
  q.context_pt = "Este teorema é a razão de chamarmos primos de 'átomos da matemática'."
  q.context_en = "This theorem is why primes are called the 'atoms of mathematics'."
  q.correct_index = 1
  q.libras_video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
end

q7.options.find_or_create_by!(text_pt: "Todo primo é ímpar") { |o| o.text_en = "Every prime is odd" }
q7.options.find_or_create_by!(text_pt: "Todo inteiro > 1 tem fatoração única em primos") { |o| o.text_en = "Every integer > 1 has a unique prime factorization" }
q7.options.find_or_create_by!(text_pt: "Há infinitos primos gêmeos") { |o| o.text_en = "There are infinitely many twin primes" }
q7.options.find_or_create_by!(text_pt: "Todo par é soma de dois primos") { |o| o.text_en = "Every even is a sum of two primes" }
q7.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "12=2²×3, 100=2²×5². Uma e só uma fatoração por inteiro. São os tijolos de tudo."
  f.body_en = "12=2²×3, 100=2²×5². One and only one factorization per integer. The bricks of everything."
end
q7.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Todo inteiro >1 tem exatamente uma fatoração em primos: 12=2²×3, 100=2²×5²."
  f.body_en = "Every integer >1 has exactly one prime factorization: 12=2²×3, 100=2²×5²."
end

puts "Seeds criadas com sucesso!"
puts "  #{QuizModule.count} módulos"
puts "  #{Question.count} questões"
puts "  #{Option.count} opções"
puts "  #{Feedback.count} feedbacks"
