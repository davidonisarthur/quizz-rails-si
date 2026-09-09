puts "Criando módulos..."

modulo1 = QuizModule.find_or_create_by!(slug: "o-que-e-primo") do |m|
  m.title_pt = "Os Blocos de Construção e os Números Primos"
  m.title_en = "The Building Blocks and Prime Numbers"
  m.unlocked = true
end

modulo2 = QuizModule.find_or_create_by!(slug: "crivo-de-eratostenes") do |m|
  m.title_pt = "Engrenagens Matemáticas: Fatoração, MMC e MDC"
  m.title_en = "Mathematical Gears: Factorization, LCM, and GCD"
  m.unlocked = true
end

modulo3 = QuizModule.find_or_create_by!(slug: "primos-e-criptografia") do |m|
  m.title_pt = "Desvendando Enigmas: A Lógica da Criptografia"
  m.title_en = "Unraveling Enigmas: The Logic of Cryptography"
  m.unlocked = true
end

modulo4 = QuizModule.find_or_create_by!(slug: "desafio-final") do |m|
  m.title_pt = "Desafio final"
  m.title_en = "Final challenge"
  m.unlocked = false
end

puts "Criando questões do Módulo 1..."

libras_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# ==============================================================================
# QUESTÃO 1 — Conceito Básico
# ==============================================================================
q1 = modulo1.questions.find_or_create_by!(body_pt: "Um número primo é um número natural maior que 1 que possui exatamente dois divisores positivos: 1 e ele mesmo.\nQual dos números abaixo é primo?") do |q|
  q.body_en = "A prime number is a natural number greater than 1 that has exactly two positive divisors: 1 and itself.\nWhich of the numbers below is prime?"
  q.context_pt = "Conceito básico e definição de números primos."
  q.context_en = "Basic concept and definition of prime numbers."
  q.correct_index = 1
  q.libras_video_url = libras_url
end

q1.options.find_or_create_by!(text_pt: "12") { |o| o.text_en = "12" }
q1.options.find_or_create_by!(text_pt: "17") { |o| o.text_en = "17" }
q1.options.find_or_create_by!(text_pt: "21") { |o| o.text_en = "21" }
q1.options.find_or_create_by!(text_pt: "25") { |o| o.text_en = "25" }

q1.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Resposta correta! O número 17 possui apenas dois divisores (1 e 17). Os outros são compostos: 12 é par, 21 = 3 × 7 e 25 = 5 × 5."
  f.body_en = "Correct answer! The number 17 has only two divisors (1 and 17). The others are composite: 12 is even, 21 = 3 × 7, and 25 = 5 × 5."
end
q1.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Lembre-se de que os números 12, 21 e 25 possuem mais de dois divisores positivos."
  f.body_en = "Incorrect. Remember that the numbers 12, 21, and 25 have more than two positive divisors."
end

# ==============================================================================
# QUESTÃO 2 — Propriedade dos Divisores
# ==============================================================================
q2 = modulo1.questions.find_or_create_by!(body_pt: "Um número primo possui exatamente dois divisores positivos.\nQual alternativa apresenta corretamente os divisores do número 31?") do |q|
  q.body_en = "A prime number has exactly two positive divisors.\nWhich alternative correctly presents the divisors of the number 31?"
  q.context_pt = "Propriedade dos Divisores - Identificação de divisores."
  q.context_en = "Divisor Property - Identifying divisors."
  q.correct_index = 0
  q.libras_video_url = libras_url
end

q2.options.find_or_create_by!(text_pt: "1 e 31") { |o| o.text_en = "1 and 31" }
q2.options.find_or_create_by!(text_pt: "1, 3 e 31") { |o| o.text_en = "1, 3 and 31" }
q2.options.find_or_create_by!(text_pt: "1, 2 e 31") { |o| o.text_en = "1, 2 and 31" }
q2.options.find_or_create_by!(text_pt: "1, 5 e 31") { |o| o.text_en = "1, 5 and 31" }

q2.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Muito bem! O número 31 é primo, portanto, seus únicos divisores são 1 e ele mesmo."
  f.body_en = "Well done! The number 31 is prime, therefore, its only divisors are 1 and itself."
end
q2.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Um número primo não pode ter mais que dois divisores. Se ele tivesse divisores como 2, 3 ou 5, não seria primo."
  f.body_en = "Incorrect. A prime number cannot have more than two divisors. If it had divisors like 2, 3, or 5, it would not be prime."
end

# ==============================================================================
# QUESTÃO 3 — Padrões e Sequências
# ==============================================================================
q3 = modulo1.questions.find_or_create_by!(body_pt: "Observe a sequência:\n2, 3, 5, 7, 11, 13, 17, 19\nQual afirmação sobre esses números é verdadeira?") do |q|
  q.body_en = "Observe the sequence:\n2, 3, 5, 7, 11, 13, 17, 19\nWhich statement about these numbers is true?"
  q.context_pt = "Padrões e Sequências - Reconhecimento de números primos."
  q.context_en = "Patterns and Sequences - Recognition of prime numbers."
  q.correct_index = 1
  q.libras_video_url = libras_url
end

q3.options.find_or_create_by!(text_pt: "Todos os números da sequência são pares.") { |o| o.text_en = "All numbers in the sequence are even." }
q3.options.find_or_create_by!(text_pt: "Todos os números da sequência são primos.") { |o| o.text_en = "All numbers in the sequence are prime." }
q3.options.find_or_create_by!(text_pt: "Todos os números da sequência são múltiplos de 3.") { |o| o.text_en = "All numbers in the sequence are multiples of 3." }
q3.options.find_or_create_by!(text_pt: "Todos os números da sequência possuem mais de dois divisores.") { |o| o.text_en = "All numbers in the sequence have more than two divisors." }

q3.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Correto! Esta é a clássica sequência dos primeiros números primos, todos divisíveis apenas por 1 e por si mesmos."
  f.body_en = "Correct! This is the classic sequence of the first prime numbers, all divisible only by 1 and themselves."
end
q3.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Verifique as propriedades desses números. Apenas o 2 é par, nenhum é múltiplo de 3 (exceto o próprio 3) e todos possuem exatamente dois divisores."
  f.body_en = "Incorrect. Check the properties of these numbers. Only 2 is even, none are multiples of 3 (except 3 itself), and all have exactly two divisors."
end

# ==============================================================================
# QUESTÃO 4 — Identificação em Lista Curta
# ==============================================================================
q4 = modulo1.questions.find_or_create_by!(body_pt: "Observe os números abaixo:\n9, 11, 14, 18 e 19\nQuantos deles são números primos?") do |q|
  q.body_en = "Observe the numbers below:\n9, 11, 14, 18, and 19\nHow many of them are prime numbers?"
  q.context_pt = "Identificação em Lista Curta - Filtragem básica."
  q.context_en = "Short List Identification - Basic filtering."
  q.correct_index = 1
  q.libras_video_url = libras_url
end

q4.options.find_or_create_by!(text_pt: "1") { |o| o.text_en = "1" }
q4.options.find_or_create_by!(text_pt: "2") { |o| o.text_en = "2" }
q4.options.find_or_create_by!(text_pt: "3") { |o| o.text_en = "3" }
q4.options.find_or_create_by!(text_pt: "4") { |o| o.text_en = "4" }

q4.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Isso mesmo! São 2 números primos: o 11 e o 19. Os números 9, 14 e 18 são compostos."
  f.body_en = "That's right! There are 2 prime numbers: 11 and 19. The numbers 9, 14, and 18 are composite."
end
q4.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Elimine os números pares (14, 18) e os múltiplos de números ímpares conhecidos (9 = 3 × 3). Sobrarão exatamente os primos."
  f.body_en = "Incorrect. Eliminate the even numbers (14, 18) and multiples of known odd numbers (9 = 3 × 3). Exactly the primes will remain."
end

# ==============================================================================
# QUESTÃO 5 — Identificação em Lista Longa
# ==============================================================================
q5 = modulo1.questions.find_or_create_by!(body_pt: "Considere o seguinte conjunto de números:\n18, 29, 35, 49 e 53\nQuais deles são números primos?") do |q|
  q.body_en = "Consider the following set of numbers:\n18, 29, 35, 49, and 53\nWhich of them are prime numbers?"
  q.context_pt = "Identificação em Lista Longa - Filtragem intermediária."
  q.context_en = "Long List Identification - Intermediate filtering."
  q.correct_index = 1
  q.libras_video_url = libras_url
end

q5.options.find_or_create_by!(text_pt: "18 e 29") { |o| o.text_en = "18 and 29" }
q5.options.find_or_create_by!(text_pt: "29 e 53") { |o| o.text_en = "29 and 53" }
q5.options.find_or_create_by!(text_pt: "35 e 53") { |o| o.text_en = "35 and 53" }
q5.options.find_or_create_by!(text_pt: "29, 49 e 53") { |o| o.text_en = "29, 49, and 53" }

q5.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Correto! O 29 e o 53 são primos. Veja por que os outros não são: 18 é par, 35 é divisível por 5, e 49 é divisível por 7."
  f.body_en = "Correct! 29 and 53 are prime. See why the others aren't: 18 is even, 35 is divisible by 5, and 49 is divisible by 7."
end
q5.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Preste atenção aos números compostos escondidos: o 35 termina em 5 (logo é divisível por 5) e o 49 é 7 × 7."
  f.body_en = "Incorrect. Pay attention to hidden composite numbers: 35 ends in 5 (so it's divisible by 5) and 49 is 7 × 7."
end

# ==============================================================================
# QUESTÃO 6 — Lógica e Contraexemplo
# ==============================================================================
q6 = modulo1.questions.find_or_create_by!(body_pt: "Pedro fez a seguinte afirmação em sala de aula:\n\"Todo número ímpar é primo.\"\nQual alternativa apresenta um contraexemplo que mostra que a afirmação de Pedro é falsa?") do |q|
  q.body_en = "Pedro made the following statement in class:\n\"Every odd number is prime.\"\nWhich alternative presents a counterexample showing that Pedro's statement is false?"
  q.context_pt = "Lógica e Contraexemplo - Pensamento crítico matemático."
  q.context_en = "Logic and Counterexample - Critical mathematical thinking."
  q.correct_index = 2
  q.libras_video_url = libras_url
end

q6.options.find_or_create_by!(text_pt: "2") { |o| o.text_en = "2" }
q6.options.find_or_create_by!(text_pt: "5") { |o| o.text_en = "5" }
q6.options.find_or_create_by!(text_pt: "9") { |o| o.text_en = "9" }
q6.options.find_or_create_by!(text_pt: "13") { |o| o.text_en = "13" }

q6.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Excelente lógica! O número 9 é ímpar, porém possui os divisores 1, 3 e 9. Portanto, ele quebra a regra dita por Pedro."
  f.body_en = "Excellent logic! The number 9 is odd, yet it has divisors 1, 3, and 9. Therefore, it breaks the rule stated by Pedro."
end
q6.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Você deve procurar um número que seja ímpar E que NÃO seja primo (ou seja, tenha mais de dois divisores)."
  f.body_en = "Incorrect. You must look for a number that is odd AND that is NOT prime (i.e., has more than two divisors)."
end

# ==============================================================================
# QUESTÃO 7 — Teste de Primalidade
# ==============================================================================
q7 = modulo1.questions.find_or_create_by!(body_pt: "Para verificar se um número é primo, costumamos testar sua divisibilidade. Após realizar testes com o número 37, um aluno concluiu corretamente que ele é um número primo.\nPortanto, quais são os únicos divisores naturais do número 37?") do |q|
  q.body_en = "To verify if a number is prime, we usually test its divisibility. After performing tests with the number 37, a student correctly concluded that it is a prime number.\nTherefore, what are the only natural divisors of the number 37?"
  q.context_pt = "Teste de Primalidade - Compreensão conceitual."
  q.context_en = "Primality Test - Conceptual understanding."
  q.correct_index = 0
  q.libras_video_url = libras_url
end

q7.options.find_or_create_by!(text_pt: "1 e 37") { |o| o.text_en = "1 and 37" }
q7.options.find_or_create_by!(text_pt: "1, 3 e 37") { |o| o.text_en = "1, 3, and 37" }
q7.options.find_or_create_by!(text_pt: "2 e 37") { |o| o.text_en = "2 and 37" }
q7.options.find_or_create_by!(text_pt: "Apenas o número 37") { |o| o.text_en = "Only the number 37" }

q7.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Perfeito. Sendo um número primo, ele obedece à regra básica de ser divisível exclusivamente por 1 e por ele mesmo."
  f.body_en = "Perfect. Being a prime number, it obeys the basic rule of being divisible exclusively by 1 and by itself."
end
q7.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Todo número primo obrigatoriamente possui exatamente dois divisores: o número 1 e o próprio número."
  f.body_en = "Incorrect. Every prime number necessarily has exactly two divisors: the number 1 and the number itself."
end

# ==============================================================================
# QUESTÃO 8 — Interpretação de Dados
# ==============================================================================
q8 = modulo1.questions.find_or_create_by!(body_pt: "Lucas analisou quatro números e escreveu em uma tabela a quantidade de divisores positivos de cada um:\n\n• 13: 2 divisores\n• 21: 4 divisores\n• 27: 4 divisores\n• 41: 2 divisores\n\nAnalisando os dados da tabela, quais desses números são primos?") do |q|
  q.body_en = "Lucas analyzed four numbers and wrote in a table the number of positive divisors for each one:\n\n• 13: 2 divisors\n• 21: 4 divisors\n• 27: 4 divisors\n• 41: 2 divisors\n\nAnalyzing the table data, which of these numbers are prime?"
  q.context_pt = "Interpretação de Dados - Extração de informação tabular."
  q.context_en = "Data Interpretation - Extraction of tabular information."
  q.correct_index = 2
  q.libras_video_url = libras_url
end

q8.options.find_or_create_by!(text_pt: "Apenas 13") { |o| o.text_en = "Only 13" }
q8.options.find_or_create_by!(text_pt: "Apenas 41") { |o| o.text_en = "Only 41" }
q8.options.find_or_create_by!(text_pt: "13 e 41") { |o| o.text_en = "13 and 41" }
q8.options.find_or_create_by!(text_pt: "21 e 27") { |o| o.text_en = "21 and 27" }

q8.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Muito bem! A definição de número primo exige exatamente 2 divisores. Segundo a tabela, apenas o 13 e o 41 atendem a essa exigência."
  f.body_en = "Well done! The definition of a prime number requires exactly 2 divisors. According to the table, only 13 and 41 meet this requirement."
end
q8.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Olhe para a tabela buscando especificamente os números que apresentem \"2 divisores\" listados ao seu lado."
  f.body_en = "Incorrect. Look at the table specifically searching for the numbers that have \"2 divisors\" listed next to them."
end

# ==============================================================================
# QUESTÃO 9 — Síntese Teórica
# ==============================================================================
q9 = modulo1.questions.find_or_create_by!(body_pt: "Observe as afirmações matemáticas abaixo:\nI. Todo número primo é maior que 1.\nII. O número 2 é o único número primo par.\nIII. Todo número composto possui mais de dois divisores positivos.\n\nAssinale a alternativa correta:") do |q|
  q.body_en = "Observe the mathematical statements below:\nI. Every prime number is greater than 1.\nII. The number 2 is the only even prime number.\nIII. Every composite number has more than two positive divisors.\n\nChoose the correct alternative:"
  q.context_pt = "Síntese Teórica - Verdadeiro ou Falso múltiplo."
  q.context_en = "Theoretical Synthesis - Multiple True or False."
  q.correct_index = 3
  q.libras_video_url = libras_url
end

q9.options.find_or_create_by!(text_pt: "Apenas I.") { |o| o.text_en = "Only I." }
q9.options.find_or_create_by!(text_pt: "Apenas I e II.") { |o| o.text_en = "Only I and II." }
q9.options.find_or_create_by!(text_pt: "Apenas II e III.") { |o| o.text_en = "Only II and III." }
q9.options.find_or_create_by!(text_pt: "I, II e III.") { |o| o.text_en = "I, II, and III." }

q9.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Isso mesmo! Todas as três afirmações estão precisas e formam a base teórica completa para o estudo da primalidade."
  f.body_en = "That's right! All three statements are accurate and form the complete theoretical basis for studying primality."
end
q9.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Analise novamente: 1 não é primo (então primos são maiores que 1), apenas o 2 é par e primo, e compostos são todos que não são primos nem 1."
  f.body_en = "Incorrect. Analyze again: 1 is not prime (so primes are greater than 1), only 2 is even and prime, and composites are all those that are neither prime nor 1."
end

# ==============================================================================
# QUESTÃO 10 — Contextualização Prática
# ==============================================================================
q10 = modulo1.questions.find_or_create_by!(body_pt: "Na computação e na criptografia, os números primos são fundamentais porque apresentam propriedades matemáticas utilizadas na construção de sistemas de segurança (como senhas e transações bancárias).\nQual das alternativas abaixo apresenta uma sequência formada apenas por números primos, que poderia ser utilizada em uma atividade introdutória sobre criptografia?") do |q|
  q.body_en = "In computing and cryptography, prime numbers are fundamental because they present mathematical properties used in building security systems (such as passwords and bank transactions).\nWhich of the alternatives below presents a sequence formed only by prime numbers, which could be used in an introductory activity on cryptography?"
  q.context_pt = "Contextualização Prática - Conexão com tecnologia."
  q.context_en = "Practical Contextualization - Connection to technology."
  q.correct_index = 0
  q.libras_video_url = libras_url
end

q10.options.find_or_create_by!(text_pt: "17, 23 e 31") { |o| o.text_en = "17, 23, and 31" }
q10.options.find_or_create_by!(text_pt: "15, 23 e 31") { |o| o.text_en = "15, 23, and 31" }
q10.options.find_or_create_by!(text_pt: "17, 27 e 31") { |o| o.text_en = "17, 27, and 31" }
q10.options.find_or_create_by!(text_pt: "21, 23 e 35") { |o| o.text_en = "21, 23, and 35" }

q10.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Excelente! A primeira alternativa é a única onde nenhum dos números é divisível por outros além de 1 e deles mesmos."
  f.body_en = "Excellent! The first alternative is the only one where none of the numbers are divisible by others besides 1 and themselves."
end
q10.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Fique de olho nos intrusos: 15 é múltiplo de 5, 27 é múltiplo de 3, e 21 e 35 são divisíveis por 7."
  f.body_en = "Incorrect. Keep an eye out for intruders: 15 is a multiple of 5, 27 is a multiple of 3, and 21 and 35 are divisible by 7."
end

#=============================================
# MODULO 2
#=============================================

libras_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# ==============================================================================
# QUESTÃO 1 — Fatoração (Inteligência Artificial)
# ==============================================================================
q1 = modulo2.questions.find_or_create_by!(body_pt: "Uma inteligência artificial está sendo treinada para identificar a fatoração prima de números naturais antes de armazená-los em um banco de dados.\nQual é a fatoração prima do número 48?") do |q|
  q.body_en = "An artificial intelligence is being trained to identify the prime factorization of natural numbers before storing them in a database.\nWhat is the prime factorization of the number 48?"
  q.context_pt = "Fatoração Prima - Inteligência Artificial."
  q.context_en = "Prime Factorization - Artificial Intelligence."
  q.correct_index = 0
  q.libras_video_url = libras_url
end

q1.options.find_or_create_by!(text_pt: "2⁴ × 3") { |o| o.text_en = "2⁴ × 3" }
q1.options.find_or_create_by!(text_pt: "2³ × 6") { |o| o.text_en = "2³ × 6" }
q1.options.find_or_create_by!(text_pt: "3 × 16") { |o| o.text_en = "3 × 16" }
q1.options.find_or_create_by!(text_pt: "4 × 12") { |o| o.text_en = "4 × 12" }

q1.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Perfeito! Dividindo 48 por 2 sucessivamente chegamos a 16 (que é 2⁴) multiplicado por 3. Todos os fatores são primos."
  f.body_en = "Perfect! Dividing 48 by 2 successively gives 16 (which is 2⁴) multiplied by 3. All factors are prime."
end
q1.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Lembre-se que em uma fatoração PRIMA, todos os números da base devem ser primos. Números como 4, 6, 12 e 16 são compostos."
  f.body_en = "Incorrect. Remember that in a PRIME factorization, all base numbers must be prime. Numbers like 4, 6, 12, and 16 are composite."
end

# ==============================================================================
# QUESTÃO 2 — Fatoração (Desenvolvimento de Jogos)
# ==============================================================================
q2 = modulo2.questions.find_or_create_by!(body_pt: "Durante o desenvolvimento de um jogo, um programador deseja dividir 54 moedas igualmente entre baús do mapa. Para isso, ele precisa conhecer a fatoração prima desse número.\nQual alternativa apresenta a resposta correta?") do |q|
  q.body_en = "During game development, a programmer wants to divide 54 coins equally among map chests. To do this, he needs to know the prime factorization of this number.\nWhich alternative presents the correct answer?"
  q.context_pt = "Fatoração Prima - Desenvolvimento de Jogos."
  q.context_en = "Prime Factorization - Game Development."
  q.correct_index = 0
  q.libras_video_url = libras_url
end

q2.options.find_or_create_by!(text_pt: "2 × 3³") { |o| o.text_en = "2 × 3³" }
q2.options.find_or_create_by!(text_pt: "2² × 3²") { |o| o.text_en = "2² × 3²" }
q2.options.find_or_create_by!(text_pt: "3 × 18") { |o| o.text_en = "3 × 18" }
q2.options.find_or_create_by!(text_pt: "6 × 9") { |o| o.text_en = "6 × 9" }

q2.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Excelente! O número 54 pode ser dividido por 2, resultando em 27. E 27 é 3³. Logo, 54 = 2 × 3³."
  f.body_en = "Excellent! The number 54 can be divided by 2, resulting in 27. And 27 is 3³. Therefore, 54 = 2 × 3³."
end
q2.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Verifique se você decompôs o número completamente até sobrarem apenas números primos."
  f.body_en = "Incorrect. Check if you have fully decomposed the number until only prime numbers remain."
end

# ==============================================================================
# QUESTÃO 3 — Engenharia Reversa (Segurança Digital)
# ==============================================================================
q3 = modulo2.questions.find_or_create_by!(body_pt: "Uma empresa está testando um algoritmo que gera chaves criptográficas utilizando fatorações primas.\nO algoritmo informou que a fatoração de um número é:\n2² × 3 × 5\nQual número originou essa fatoração?") do |q|
  q.body_en = "A company is testing an algorithm that generates cryptographic keys using prime factorizations.\nThe algorithm reported that a number's factorization is:\n2² × 3 × 5\nWhich number originated this factorization?"
  q.context_pt = "Recomposição de Fatores - Segurança Digital."
  q.context_en = "Factor Recomposition - Digital Security."
  q.correct_index = 2
  q.libras_video_url = libras_url
end

q3.options.find_or_create_by!(text_pt: "30") { |o| o.text_en = "30" }
q3.options.find_or_create_by!(text_pt: "45") { |o| o.text_en = "45" }
q3.options.find_or_create_by!(text_pt: "60") { |o| o.text_en = "60" }
q3.options.find_or_create_by!(text_pt: "120") { |o| o.text_en = "120" }

q3.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Muito bem! Para recompor o número, basta calcular a potência e multiplicar os fatores: 4 × 3 × 5 = 60."
  f.body_en = "Very well! To recompose the number, just calculate the power and multiply the factors: 4 × 3 × 5 = 60."
end
q3.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Lembre-se de calcular 2² como 4 e depois multiplicar pelos outros fatores (3 e 5)."
  f.body_en = "Incorrect. Remember to calculate 2² as 4 and then multiply by the other factors (3 and 5)."
end

# ==============================================================================
# QUESTÃO 4 — Engenharia Reversa (Segurança Avançada)
# ==============================================================================
q4 = modulo2.questions.find_or_create_by!(body_pt: "Durante a geração de uma chave criptográfica mais complexa, um algoritmo utilizou os seguintes fatores primos:\n2 × 3 × 5 × 7\nQual número foi utilizado?") do |q|
  q.body_en = "During the generation of a more complex cryptographic key, an algorithm used the following prime factors:\n2 × 3 × 5 × 7\nWhich number was used?"
  q.context_pt = "Recomposição de Fatores - Múltiplos Primos."
  q.context_en = "Factor Recomposition - Multiple Primes."
  q.correct_index = 1
  q.libras_video_url = libras_url
end

q4.options.find_or_create_by!(text_pt: "180") { |o| o.text_en = "180" }
q4.options.find_or_create_by!(text_pt: "210") { |o| o.text_en = "210" }
q4.options.find_or_create_by!(text_pt: "240") { |o| o.text_en = "240" }
q4.options.find_or_create_by!(text_pt: "420") { |o| o.text_en = "420" }

q4.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Isso mesmo! Multiplicando passo a passo: 2 × 3 = 6; 6 × 5 = 30; 30 × 7 = 210."
  f.body_en = "That's right! Multiplying step by step: 2 × 3 = 6; 6 × 5 = 30; 30 × 7 = 210."
end
q4.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Tente multiplicar os números em sequência: primeiro 2×3, depois multiplique o resultado por 5, e o novo resultado por 7."
  f.body_en = "Incorrect. Try multiplying the numbers in sequence: first 2×3, then multiply the result by 5, and the new result by 7."
end

# ==============================================================================
# QUESTÃO 5 — Validação de Fatoração (IA)
# ==============================================================================
q5 = modulo2.questions.find_or_create_by!(body_pt: "Um sistema de IA precisa verificar se uma fatoração foi realizada corretamente.\nQual das alternativas apresenta a fatoração prima correta do número 90?") do |q|
  q.body_en = "An AI system needs to verify if a factorization was performed correctly.\nWhich of the alternatives presents the correct prime factorization of the number 90?"
  q.context_pt = "Validação de Fatores Primos - IA."
  q.context_en = "Prime Factors Validation - AI."
  q.correct_index = 0
  q.libras_video_url = libras_url
end

q5.options.find_or_create_by!(text_pt: "2 × 3² × 5") { |o| o.text_en = "2 × 3² × 5" }
q5.options.find_or_create_by!(text_pt: "2² × 3 × 5") { |o| o.text_en = "2² × 3 × 5" }
q5.options.find_or_create_by!(text_pt: "3² × 10") { |o| o.text_en = "3² × 10" }
q5.options.find_or_create_by!(text_pt: "5 × 18") { |o| o.text_en = "5 × 18" }

q5.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Correto! 90 = 2 × 45 = 2 × (3² × 5). As alternativas com 10 e 18 estão erradas porque esses números não são primos."
  f.body_en = "Correct! 90 = 2 × 45 = 2 × (3² × 5). Alternatives with 10 and 18 are wrong because those numbers aren't prime."
end
q5.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Lembre-se que você deve focar apenas em alternativas que contenham *exclusivamente* números primos (2, 3, 5, etc)."
  f.body_en = "Incorrect. Remember that you should only focus on alternatives that contain *exclusively* prime numbers (2, 3, 5, etc)."
end

# ==============================================================================
# QUESTÃO 6 — Auditoria de Erros (IA)
# ==============================================================================
q6 = modulo2.questions.find_or_create_by!(body_pt: "Uma IA de auditoria analisou quatro bancos de dados e encontrou um erro em uma das fatorações primas armazenadas.\nQual das alternativas abaixo apresenta o cálculo incorreto e deve ser sinalizada pela IA?") do |q|
  q.body_en = "An auditing AI analyzed four databases and found an error in one of the stored prime factorizations.\nWhich of the alternatives below presents the incorrect calculation and should be flagged by the AI?"
  q.context_pt = "Auditoria e Detecção de Erros - IA."
  q.context_en = "Auditing and Error Detection - AI."
  q.correct_index = 3
  q.libras_video_url = libras_url
end

q6.options.find_or_create_by!(text_pt: "72 = 2³ × 3²") { |o| o.text_en = "72 = 2³ × 3²" }
q6.options.find_or_create_by!(text_pt: "84 = 2² × 3 × 7") { |o| o.text_en = "84 = 2² × 3 × 7" }
q6.options.find_or_create_by!(text_pt: "96 = 2⁵ × 3") { |o| o.text_en = "96 = 2⁵ × 3" }
q6.options.find_or_create_by!(text_pt: "100 = 2³ × 5²") { |o| o.text_en = "100 = 2³ × 5²" }

q6.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Perfeito! A IA deve sinalizar o número 100, pois ele é igual a 4 × 25, ou seja, 2² × 5², e não 2³ (que seria 8)."
  f.body_en = "Perfect! The AI should flag the number 100, because it equals 4 × 25, which is 2² × 5², not 2³ (which would be 8)."
end
q6.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Calcule cada alternativa cuidadosamente para achar o erro. Por exemplo, calcule quanto é 2³ × 5²."
  f.body_en = "Incorrect. Calculate each alternative carefully to find the error. For example, calculate what 2³ × 5² equals."
end

# ==============================================================================
# QUESTÃO 7 — Máximo Divisor Comum (Segurança)
# ==============================================================================
q7 = modulo2.questions.find_or_create_by!(body_pt: "Para criar uma chave de acesso, um sistema precisa encontrar o maior divisor comum (MDC) entre os números 36 e 48.\nQual valor será utilizado?") do |q|
  q.body_en = "To create an access key, a system needs to find the greatest common divisor (GCD) between the numbers 36 and 48.\nWhat value will be used?"
  q.context_pt = "MDC - Segurança Digital."
  q.context_en = "GCD - Digital Security."
  q.correct_index = 2
  q.libras_video_url = libras_url
end

q7.options.find_or_create_by!(text_pt: "6") { |o| o.text_en = "6" }
q7.options.find_or_create_by!(text_pt: "8") { |o| o.text_en = "8" }
q7.options.find_or_create_by!(text_pt: "12") { |o| o.text_en = "12" }
q7.options.find_or_create_by!(text_pt: "18") { |o| o.text_en = "18" }

q7.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Exato! Ambos os números são divisíveis por 2, 3, 4 e 6, mas o MAIOR divisor comum a eles é o 12 (36÷12=3 e 48÷12=4)."
  f.body_en = "Exactly! Both numbers are divisible by 2, 3, 4, and 6, but the GREATEST common divisor is 12 (36÷12=3 and 48÷12=4)."
end
q7.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Tente listar os divisores do 36 e os divisores do 48, depois encontre o maior número que se repete nas duas listas."
  f.body_en = "Incorrect. Try listing the divisors of 36 and the divisors of 48, then find the largest number that repeats in both lists."
end

# ==============================================================================
# QUESTÃO 8 — Mínimo Múltiplo Comum (Jogos)
# ==============================================================================
q8 = modulo2.questions.find_or_create_by!(body_pt: "Em um jogo, duas habilidades especiais ficam disponíveis em intervalos diferentes:\nHabilidade A: a cada 12 segundos.\nHabilidade B: a cada 18 segundos.\nApós quanto tempo as duas habilidades estarão disponíveis ao mesmo tempo novamente?") do |q|
  q.body_en = "In a game, two special abilities become available at different intervals:\nAbility A: every 12 seconds.\nAbility B: every 18 seconds.\nAfter how much time will both abilities be available at the same time again?"
  q.context_pt = "MMC - Sincronização em Jogos."
  q.context_en = "LCM - Synchronization in Games."
  q.correct_index = 2
  q.libras_video_url = libras_url
end

q8.options.find_or_create_by!(text_pt: "24 segundos") { |o| o.text_en = "24 seconds" }
q8.options.find_or_create_by!(text_pt: "30 segundos") { |o| o.text_en = "30 seconds" }
q8.options.find_or_create_by!(text_pt: "36 segundos") { |o| o.text_en = "36 seconds" }
q8.options.find_or_create_by!(text_pt: "72 segundos") { |o| o.text_en = "72 seconds" }

q8.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Correto! Isso é um cálculo de MMC. Os múltiplos de 12 (12, 24, 36...) e de 18 (18, 36...) se encontram pela primeira vez no número 36."
  f.body_en = "Correct! This is an LCM calculation. The multiples of 12 (12, 24, 36...) and 18 (18, 36...) meet for the first time at the number 36."
end
q8.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Você precisa encontrar o Mínimo Múltiplo Comum (MMC). Qual é o menor número que está tanto na tabuada do 12 quanto na do 18?"
  f.body_en = "Incorrect. You need to find the Least Common Multiple (LCM). What is the smallest number that is in both the 12 and 18 multiplication tables?"
end

# ==============================================================================
# QUESTÃO 9 — Aplicação Prática de MDC (Jogos)
# ==============================================================================
q9 = modulo2.questions.find_or_create_by!(body_pt: "Um desenvolvedor está criando um sistema de recompensas para o seu jogo. Ele tem 80 moedas de ouro e 120 poções de vida e quer dividi-las no maior número possível de baús.\nTodos os baús devem ter a mesma quantidade de moedas e poções, sem sobrar nada. Quantos baús ele conseguirá criar?") do |q|
  q.body_en = "A developer is creating a reward system for his game. He has 80 gold coins and 120 health potions and wants to divide them into the largest possible number of chests.\nAll chests must have the same amount of coins and potions, with nothing left over. How many chests will he be able to create?"
  q.context_pt = "MDC - Divisão de Recursos em Jogos."
  q.context_en = "GCD - Resource Division in Games."
  q.correct_index = 2
  q.libras_video_url = libras_url
end

q9.options.find_or_create_by!(text_pt: "10 baús") { |o| o.text_en = "10 chests" }
q9.options.find_or_create_by!(text_pt: "20 baús") { |o| o.text_en = "20 chests" }
q9.options.find_or_create_by!(text_pt: "40 baús") { |o| o.text_en = "40 chests" }
q9.options.find_or_create_by!(text_pt: "60 baús") { |o| o.text_en = "60 chests" }

q9.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Ótimo! Calculando o MDC entre 80 e 120, encontramos 40. Ele criará 40 baús, cada um contendo exatamente 2 moedas e 3 poções."
  f.body_en = "Great! Calculating the GCD between 80 and 120, we find 40. He will create 40 chests, each containing exactly 2 coins and 3 potions."
end
q9.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Problemas de divisão igualitária com aproveitamento máximo envolvem MDC. Calcule o Máximo Divisor Comum de 80 e 120."
  f.body_en = "Incorrect. Equal division problems with maximum usage involve GCD. Calculate the Greatest Common Divisor of 80 and 120."
end

# ==============================================================================
# QUESTÃO 10 — Missão Final
# ==============================================================================
q10 = modulo2.questions.find_or_create_by!(body_pt: "Você faz parte da equipe de desenvolvimento de um sistema de autenticação.\nPara concluir o processo, é necessário responder corretamente às duas etapas abaixo.\n\nO MDC entre 24 e 36 é: ___\nO MMC entre 6 e 8 é: ___\n\nQual alternativa contém os dois resultados corretos?") do |q|
  q.body_en = "You are part of the development team for an authentication system.\nTo complete the process, you must answer the two steps below correctly.\n\nThe GCD between 24 and 36 is: ___\nThe LCM between 6 and 8 is: ___\n\nWhich alternative contains both correct results?"
  q.context_pt = "Missão Final - MDC e MMC combinados."
  q.context_en = "Final Mission - GCD and LCM combined."
  q.correct_index = 0
  q.libras_video_url = libras_url
end

q10.options.find_or_create_by!(text_pt: "MDC = 12 e MMC = 24") { |o| o.text_en = "GCD = 12 and LCM = 24" }
q10.options.find_or_create_by!(text_pt: "MDC = 6 e MMC = 24") { |o| o.text_en = "GCD = 6 and LCM = 24" }
q10.options.find_or_create_by!(text_pt: "MDC = 12 e MMC = 48") { |o| o.text_en = "GCD = 12 and LCM = 48" }
q10.options.find_or_create_by!(text_pt: "MDC = 6 e MMC = 48") { |o| o.text_en = "GCD = 6 and LCM = 48" }

q10.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Missão cumprida! O maior divisor que serve tanto para 24 quanto para 36 é 12. Já o menor múltiplo que serve tanto para 6 quanto para 8 é 24."
  f.body_en = "Mission accomplished! The greatest divisor that works for both 24 and 36 is 12. The least common multiple for both 6 and 8 is 24."
end
q10.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Faça um processo por vez. Primeiro ache o MDC (divisão) entre 24 e 36. Depois o MMC (multiplicação) de 6 e 8."
  f.body_en = "Incorrect. Do one process at a time. First find the GCD (division) between 24 and 36. Then the LCM (multiplication) of 6 and 8."
end

#===================================================
# MODULO 3
#===================================================
# ==============================================================================
# QUESTÃO 1 — Conceito Prático (Regra de Transformação)
# ==============================================================================
q1 = modulo3.questions.find_or_create_by!(body_pt: "Do ponto de vista lógico, o processo de criptografia funciona como uma \"regra de transformação\". Uma mensagem original passa por um segredo matemático que altera suas letras, gerando um código.\nPara que o destinatário consiga ler a mensagem original, o sistema de segurança deve fazer o quê?") do |q|
  q.body_en = "From a logical standpoint, the encryption process works like a 'transformation rule'. An original message passes through a mathematical secret that alters its letters, generating a code.\nIn order for the recipient to read the original message, what must the security system do?"
  q.context_pt = "Conceito Prático - Regra de transformação e reversibilidade."
  q.context_en = "Practical Concept - Transformation rule and reversibility."
  q.correct_index = 1
  q.libras_video_url = libras_url
end

q1.options.find_or_create_by!(text_pt: "Aplicar a mesma regra de transformação novamente.") { |o| o.text_en = "Apply the same transformation rule again." }
q1.options.find_or_create_by!(text_pt: "Aplicar a regra inversa (desfazer a operação) para voltar ao início.") { |o| o.text_en = "Apply the inverse rule (undo the operation) to go back to the beginning." }
q1.options.find_or_create_by!(text_pt: "Apagar o histórico de mensagens enviadas.") { |o| o.text_en = "Delete the sent message history." }
q1.options.find_or_create_by!(text_pt: "Multiplicar o text por zero para limpar o código.") { |o| o.text_en = "Multiply the text by zero to clear the code." }

q1.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Muito bem! Para ler a mensagem original, precisamos sempre desfazer a operação que escondeu os dados, aplicando a regra inversa (descriptografar)."
  f.body_en = "Very well! To read the original message, we always need to undo the operation that hid the data, applying the inverse rule (decrypting)."
end
q1.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Pense no que fazemos quando queremos desfazer uma ação: nós aplicamos a operação inversa para retornar ao estado original."
  f.body_en = "Incorrect. Think about what we do when we want to undo an action: we apply the inverse operation to return to the original state."
end

# ==============================================================================
# QUESTÃO 2 — A Cifra de César (Regra de Somar)
# ==============================================================================
q2 = modulo3.questions.find_or_create_by!(body_pt: "Uma das formas mais antigas de esconder mensagens consiste em \"empurrar\" as letras do alfabeto algumas posições para a frente. Imagine uma regra onde cada letra avança 3 posições (+3). Ou seja: A vira D, B vira E, C vira F, e assim por diante.\nSeguindo essa regra de somar 3 posições, como a palavra BOA seria escrita em código?") do |q|
  q.body_en = "One of the oldest ways to hide messages consists of 'pushing' the letters of the alphabet a few positions forward. Imagine a rule where each letter advances 3 positions (+3). That is: A becomes D, B becomes E, C becomes F, and so on.\nFollowing this rule of adding 3 positions, how would the word BOA be written in code?"
  q.context_pt = "A Cifra de César - Regra de deslocamento positivo."
  q.context_en = "The Caesar Cipher - Positive shift rule."
  q.correct_index = 0
  q.libras_video_url = libras_url
end

q2.options.find_or_create_by!(text_pt: "ERD") { |o| o.text_en = "ERD" }
q2.options.find_or_create_by!(text_pt: "FSE") { |o| o.text_en = "FSE" }
q2.options.find_or_create_by!(text_pt: "CPN") { |o| o.text_en = "CPN" }
q2.options.find_or_create_by!(text_pt: "AMZ") { |o| o.text_en = "AMZ" }

q2.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Isso mesmo! Avançando 3 posições no alfabeto: B vira E, O vira R, e A vira D. Portanto, formamos o código ERD."
  f.body_en = "That's right! Advancing 3 positions in the alphabet: B becomes E, O becomes R, and A becomes D. Therefore, we form the code ERD."
end
q2.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Tente contar no alfabeto pulando exatamente 3 letras para a frente a partir de cada letra da palavra BOA."
  f.body_en = "Incorrect. Try counting in the alphabet skipping exactly 3 letters forward from each letter of the word BOA."
end

# ==============================================================================
# QUESTÃO 3 — Descriptografando (Regra de Subtrair)
# ==============================================================================
q3 = modulo3.questions.find_or_create_by!(body_pt: "Se para esconder uma mensagem nós avançamos as letras no alfabeto (+), para ler a mensagem original precisamos fazer a operação inversa: voltar as letras no alfabeto (-).\nUm sistema de segurança usou a regra de avançar 2 posições (+2) para esconder uma palavra. Você interceptou o código gerado, que foi: ECUC.\nFazendo a operação inversa (voltando 2 posições em cada letra), qual era a palavra original?") do |q|
  q.body_en = "If to hide a message we advance the letters in the alphabet (+), to read the original message we need to perform the inverse operation: move the letters back in the alphabet (-).\nA security system used the rule of advancing 2 positions (+2) to hide a word. You intercepted the generated code, which was: ECUC.\nPerforming the inverse operation (moving each letter back 2 positions), what was the original word?"
  q.context_pt = "Descriptografando - Regra de deslocamento negativo (inversa)."
  q.context_en = "Decrypting - Negative shift rule (inverse)."
  q.correct_index = 2
  q.libras_video_url = libras_url
end

q3.options.find_or_create_by!(text_pt: "BOLO") { |o| o.text_en = "BOLO" }
q3.options.find_or_create_by!(text_pt: "DATA") { |o| o.text_en = "DATA" }
q3.options.find_or_create_by!(text_pt: "CASA") { |o| o.text_en = "CASA" }
q3.options.find_or_create_by!(text_pt: "RATO") { |o| o.text_en = "RATO" }

q3.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Excelente lógica! Voltando 2 casas no alfabeto para cada letra: E vira C, C vira A, U vira S, e C vira A, revelando a palavra CASA."
  f.body_en = "Excellent logic! Going back 2 spots in the alphabet for each letter: E becomes C, C becomes A, U becomes S, and C becomes A, revealing the word CASA."
end
q3.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Lembre-se de subtrair (voltar) 2 posições no alfabeto para cada uma das letras do código ECUC."
  f.body_en = "Incorrect. Remember to subtract (go back) 2 positions in the alphabet for each of the letters in the code ECUC."
end

# ==============================================================================
# QUESTÃO 4 — O Limite do Alfabeto (Lógica de Ciclo)
# ==============================================================================
q4 = modulo3.questions.find_or_create_by!(body_pt: "O nosso alfabeto tem 26 letras (de A até Z). Quando usamos uma regra de avançar posições, a última letra (Z) fica sem ter para onde ir. Para resolver isso de forma lógica, os sistemas fazem o alfabeto funcionar como um relógio: quando chega no fim, ele dá a volta e recomeça do A.\nSabendo disso, se aplicarmos a regra de avançar 3 posições (+3), qual letra representará o Z?") do |q|
  q.body_en = "Our alphabet has 26 letters (from A to Z). When we use a rule to advance positions, the last letter (Z) has nowhere to go. To solve this logically, systems make the alphabet work like a clock: when it reaches the end, it wraps around and restarts from A.\nKnowing this, if we apply the rule of advancing 3 positions (+3), which letter will represent Z?"
  q.context_pt = "Limite do Alfabeto - Comportamento cíclico."
  q.context_en = "Alphabet Limit - Cyclic behavior."
  q.correct_index = 2
  q.libras_video_url = libras_url
end

q4.options.find_or_create_by!(text_pt: "A") { |o| o.text_en = "A" }
q4.options.find_or_create_by!(text_pt: "B") { |o| o.text_en = "B" }
q4.options.find_or_create_by!(text_pt: "C") { |o| o.text_en = "C" }
q4.options.find_or_create_by!(text_pt: "D") { |o| o.text_en = "D" }

q4.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Correto! Como o alfabeto funciona em ciclo, depois do Z nós recomeçamos: o 1º pulo vai para A, o 2º vai para B e o 3º vai para C."
  f.body_en = "Correct! Since the alphabet works in a cycle, after Z we restart: the 1st jump goes to A, the 2nd goes to B, and the 3rd goes to C."
end
q4.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Imagine o alfabeto desenhado em um círculo: logo após a letra Z, a próxima letra é o A. Conte 3 passos para frente a partir do Z."
  f.body_en = "Incorrect. Imagine the alphabet drawn in a circle: right after the letter Z, the next letter is A. Count 3 steps forward starting from Z."
end

# ==============================================================================
# QUESTÃO 5 — Descobrindo o Padrão (Raciocínio Lógico)
# ==============================================================================
q5 = modulo3.questions.find_or_create_by!(body_pt: "Um programador de jogos estava analisando os arquivos do sistema e percebeu que o computador pegou a palavra REDE e a transformou no código SFEF.\nAnalisando a mudança das letras, qual foi a regra matemática de deslocamento que o computador utilizou?") do |q|
  q.body_en = "A game programmer was analyzing system files and noticed that the computer took the word REDE and transformed it into the code SFEF.\nAnalyzing the change in letters, what was the mathematical shift rule that the computer used?"
  q.context_pt = "Descobrindo o Padrão - Identificação de regras."
  q.context_en = "Finding the Pattern - Identification of rules."
  q.correct_index = 0
  q.libras_video_url = libras_url
end

q5.options.find_or_create_by!(text_pt: "Avançar 1 posição (+1) em cada letra.") { |o| o.text_en = "Advance 1 position (+1) for each letter." }
q5.options.find_or_create_by!(text_pt: "Avançar 2 posições (+2) em cada letra.") { |o| o.text_en = "Advance 2 positions (+2) for each letter." }
q5.options.find_or_create_by!(text_pt: "Voltar 1 posição (-1) em cada letra.") { |o| o.text_en = "Move back 1 position (-1) for each letter." }
q5.options.find_or_create_by!(text_pt: "Voltar 2 posições (-2) em cada letra.") { |o| o.text_en = "Move back 2 positions (-2) for each letter." }

q5.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Muito bem! Comparando as letras originais com as do código: R para S (+1), E para F (+1), D para E (+1) e E para F (+1). A regra é avançar 1 posição."
  f.body_en = "Well done! Comparing the original letters with the code: R to S (+1), E to F (+1), D to E (+1), and E to F (+1). The rule is to advance 1 position."
end
q5.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Observe a distância no alfabeto entre a letra original R e a letra codificada S. É uma distância bem curta e para frente."
  f.body_en = "Incorrect. Note the distance in the alphabet between the original letter R and the coded letter S. It is a very short distance forward."
end

# ==============================================================================
# QUESTÃO 6 — Contando Possibilidades (Análise Combinatória)
# ==============================================================================
q6 = modulo3.questions.find_or_create_by!(body_pt: "Um hacker descobriu que um usuário protegeu sua senha usando a Cifra de César (que apenas empurra o alfabeto inteiro um número fixo de vezes). O hacker sabe que o alfabeto tem 26 letras no total.\nExcluindo o \"pulo zero\" (que deixaria a senha igual), quantas opções de pulos diferentes existem no máximo para o hacker testar até descobrir a senha por tentativa e erro?") do |q|
  q.body_en = "A hacker discovered that a user protected their password using the Caesar Cipher (which only shifts the entire alphabet a fixed number of times). The hacker knows that the alphabet has 26 letters in total.\nExcluding the 'zero shift' (which would leave the password the same), how many different shift options at most exist for the hacker to test until discovering the password by trial and error?"
  q.context_pt = "Contando Possibilidades - Análise combinatória simples."
  q.context_en = "Counting Possibilities - Simple combinatorics."
  q.correct_index = 1
  q.libras_video_url = libras_url
end

q6.options.find_or_create_by!(text_pt: "10 opções") { |o| o.text_en = "10 options" }
q6.options.find_or_create_by!(text_pt: "25 opções") { |o| o.text_en = "25 options" }
q6.options.find_or_create_by!(text_pt: "50 opções") { |o| o.text_en = "50 options" }
q6.options.find_or_create_by!(text_pt: "Mais de 1000 opções") { |o| o.text_en = "More than 1000 options" }

q6.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Perfeito! Como existem 26 letras no alfabeto, existem apenas 25 deslocamentos possíveis além do original. Isso torna essa cifra matematicamente muito fácil de quebrar."
  f.body_en = "Perfect! Since there are 26 letters in the alphabet, there are only 25 possible shifts other than the original. This makes this cipher mathematically very easy to break."
end
q6.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Se o alfabeto tem 26 letras, você pode empurrar de 1 até 25 vezes. Pular 26 vezes faria o alfabeto dar uma volta completa e voltar exatamente para as mesmas letras originais."
  f.body_en = "Incorrect. If the alphabet has 26 letters, you can shift from 1 to 25 times. Shifting 26 times would make the alphabet do a full loop and return exactly to the same original letters."
end

# ==============================================================================
# QUESTÃO 7 — Criptografia com Números (Substituição)
# ==============================================================================
q7 = modulo3.questions.find_or_create_by!(body_pt: "Outra forma simples de criptografia é trocar as letras por sua posição no alfabeto: A=1, B=2, C=3, D=4... e O=15. Depois, aplica-se uma conta. Um sistema foi programado para pegar o número de cada letra e somar +10.\nPor exemplo: a letra C (que vale 3) vira o número 13 (3 + 10 = 13).\nSeguindo essa regra de somar 10 aos valores originais, qual será a sequência de números gerada para esconder a palavra DADO? (Dados: D=4, A=1, O=15).") do |q|
  q.body_en = "Another simple form of cryptography is replacing letters with their position in the alphabet: A=1, B=2, C=3, D=4... and O=15. Then, a math operation is applied. A system was programmed to take the number of each letter and add +10.\nFor example: the letter C (which is worth 3) becomes the number 13 (3 + 10 = 13).\nFollowing this rule of adding 10 to the original values, what will be the sequence of numbers generated to hide the word DADO? (Given: D=4, A=1, O=15)."
  q.context_pt = "Criptografia com Números - Substituição algébrica simples."
  q.context_en = "Number Cryptography - Simple algebraic substitution."
  q.correct_index = 2
  q.libras_video_url = libras_url
end

q7.options.find_or_create_by!(text_pt: "[4, 1, 4, 15]") { |o| o.text_en = "[4, 1, 4, 15]" }
q7.options.find_or_create_by!(text_pt: "[10, 10, 10, 10]") { |o| o.text_en = "[10, 10, 10, 10]" }
q7.options.find_or_create_by!(text_pt: "[14, 11, 14, 25]") { |o| o.text_en = "[14, 11, 14, 25]" }
q7.options.find_or_create_by!(text_pt: "[15, 12, 15, 26]") { |o| o.text_en = "[15, 12, 15, 26]" }

q7.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Isso mesmo! Somando 10 a cada valor: D(4+10=14), A(1+10=11), D(4+10=14) e O(15+10=25). A sequência numérica correta é [14, 11, 14, 25]."
  f.body_en = "That's right! Adding 10 to each value: D(4+10=14), A(1+10=11), D(4+10=14), and O(15+10=25). The correct numerical sequence is [14, 11, 14, 25]."
end
q7.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Você deve pegar os valores originais de cada letra fornecidos no enunciado (4, 1, 4, 15) e somar 10 a cada um deles individualmente."
  f.body_en = "Incorrect. You must take the original values of each letter provided in the prompt (4, 1, 4, 15) and add 10 to each of them individually."
end

# ==============================================================================
# QUESTÃO 8 — Estatística Visual (Análise de Padrões)
# ==============================================================================
q8 = modulo3.questions.find_or_create_by!(body_pt: "Na nossa língua portuguesa, se pegarmos um livro inteiro, a letra que mais se repete disparada em todo o texto é a vogal A.\nUm sistema de Inteligência Artificial analisou uma mensagem secreta muito longa e percebeu que o símbolo @ aparece muito mais vezes do que qualquer outro símbolo.\nUsando a lógica da estatística, qual é a conclusão mais provável que a IA vai chegar?") do |q|
  q.body_en = "In our Portuguese language, if we take an entire book, the letter that repeats by far the most throughout the text is the vowel A.\nAn Artificial Intelligence system analyzed a very long secret message and noticed that the symbol @ appears much more often than any other symbol.\nUsing the logic of statistics, what is the most likely conclusion the AI will reach?"
  q.context_pt = "Estatística Visual - Análise de frequência e padrões."
  q.context_en = "Visual Statistics - Frequency and pattern analysis."
  q.correct_index = 0
  q.libras_video_url = libras_url
end

q8.options.find_or_create_by!(text_pt: "O símbolo @ representa a letra A.") { |o| o.text_en = "The symbol @ represents the letter A." }
q8.options.find_or_create_by!(text_pt: "O texto original foi escrito em inglês.") { |o| o.text_en = "The original text was written in English." }
q8.options.find_or_create_by!(text_pt: "O computador está quebrado.") { |o| o.text_en = "The computer is broken." }
q8.options.find_or_create_by!(text_pt: "O símbolo @ representa a última letra do alfabeto.") { |o| o.text_en = "The symbol @ represents the last letter of the alphabet." }

q8.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Excelente! Esta técnica matemática se chama Análise de Frequência. Se a letra A é a mais comum no idioma natural, o símbolo substituto mais frequente no código gerado muito provavelmente esconde a letra A."
  f.body_en = "Excellent! This mathematical technique is called Frequency Analysis. If the letter A is the most common in the natural language, the most frequent substitute symbol in the generated code most likely hides the letter A."
end
q8.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Pense pelo lado da estatística: se um símbolo misterioso aparece exatamente na mesma proporção alta que uma letra real costuma aparecer, a lógica indica que eles se correspondem."
  f.body_en = "Incorrect. Think about it from the statistical side: if a mysterious symbol appears in exactly the same high proportion that a real letter usually appears, logic indicates they correspond to each other."
end

# ==============================================================================
# QUESTÃO 9 — Conexão com o Mundo Real (Números Primos)
# ==============================================================================
q9 = modulo3.questions.find_or_create_by!(body_pt: "Hoje em dia, os computadores conseguem testar milhões de combinações de letras por segundo, o que torna as cifras de \"empurrar letras\" fáceis de quebrar. Por isso, a segurança atual da internet (como as chaves do PIX) usa uma matemática diferente.\nDe acordo com o que aprendemos nos módulos passados, qual conceito matemático é a base da segurança digital moderna?") do |q|
  q.body_en = "Nowadays, computers can test millions of letter combinations per second, which makes 'letter-pushing' ciphers easy to break. Because of this, modern internet security (like PIX keys) uses a different kind of math.\nAccording to what we learned in past modules, which mathematical concept is the foundation of modern digital security?"
  q.context_pt = "Mundo Real - Conexão computacional com números primos."
  q.context_en = "Real World - Computational connection to prime numbers."
  q.correct_index = 1
  q.libras_video_url = libras_url
end

q9.options.find_or_create_by!(text_pt: "Gráficos cheios de barras coloridas.") { |o| o.text_en = "Charts full of colorful bars." }
q9.options.find_or_create_by!(text_pt: "Multiplicação de números primos gigantescos que são muito difíceis de fatorar.") { |o| o.text_en = "Multiplication of gigantic prime numbers that are very difficult to factor." }
q9.options.find_or_create_by!(text_pt: "Contar quantas letras existem em uma palavra.") { |o| o.text_en = "Counting how many letters exist in a word." }
q9.options.find_or_create_by!(text_pt: "Fazer divisões por zero.") { |o| o.text_en = "Performing divisions by zero." }

q9.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Muito bem! A segurança moderna depende de números primos imensos. Multiplicá-los é super rápido para o computador, mas fazer o caminho de volta (descobrir quais primos foram multiplicados através da fatoração) levaria milhares de anos!"
  f.body_en = "Well done! Modern security depends on immense prime numbers. Multiplying them is super fast for the computer, but doing the reverse path (finding out which primes were multiplied through factorization) would take thousands of years!"
end
q9.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Lembra do que estudamos e fatoramos exaustivamente nos Módulos 1 e 2? Os números primos são as verdadeiras engrenagens secretas da criptografia moderna."
  f.body_en = "Incorrect. Remember what we studied and factored exhaustively in Modules 1 and 2? Prime numbers are the true secret gears of modern cryptography."
end

# ==============================================================================
# QUESTÃO 10 — Missão Final (O Desafio do Código)
# ==============================================================================
q10 = modulo3.questions.find_or_create_by!(body_pt: "Para garantir a segurança das informações do seu grupo de estudos, você decidiu criar um código secreto. A regra escolhida por vocês foi: pegar a palavra e avançar 2 posições (+2) em cada letra no alfabeto.\nSe a palavra que você quer esconder é GATO, como ela ficará escrita em código para ser enviada?") do |q|
  q.body_en = "To ensure the security of your study group's information, you decided to create a secret code. The rule you chose was: take the word and advance 2 positions (+2) for each letter in the alphabet.\nIf the word you want to hide is GATO, how will it be written in code to be sent?"
  q.context_pt = "Missão Final - Aplicação de criptografia direta."
  q.context_en = "Final Mission - Direct cryptography application."
  q.correct_index = 1
  q.libras_video_url = libras_url
end

q10.options.find_or_create_by!(text_pt: "HBUP") { |o| o.text_en = "HBUP" }
q10.options.find_or_create_by!(text_pt: "ICVQ") { |o| o.text_en = "ICVQ" }
q10.options.find_or_create_by!(text_pt: "JDWR") { |o| o.text_en = "JDWR" }
q10.options.find_or_create_by!(text_pt: "FZSN") { |o| o.text_en = "FZSN" }

q10.feedbacks.find_or_create_by!(kind: "correct") do |f|
  f.body_pt = "Missão cumprida! Somando 2 posições no alfabeto para cada letra: G vira I, A vira C, T vira V e O vira Q. O código criptografado perfeito é ICVQ!"
  f.body_en = "Mission accomplished! Adding 2 positions in the alphabet for each letter: G becomes I, A becomes C, T becomes V, and O becomes Q. The perfect encrypted code is ICVQ!"
end
q10.feedbacks.find_or_create_by!(kind: "incorrect") do |f|
  f.body_pt = "Incorreto. Avance exatamente 2 posições no alfabeto para cada caractere da palavra GATO (por exemplo, após a letra G vem o H, e depois o I)."
  f.body_en = "Incorrect. Advance exactly 2 positions in the alphabet for each character of the word GATO (for example, after the letter G comes H, and then I)."
end






puts "Seeds criadas com sucesso!"
puts "  #{QuizModule.count} módulos"
puts "  #{Question.count} questões"
puts "  #{Option.count} opções"
puts "  #{Feedback.count} feedbacks"
