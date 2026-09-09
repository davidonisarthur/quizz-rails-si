# PrimoQuiz: Plataforma Web Interativa e Acessível para o Ensino de Teoria dos Números a Estudantes Surdos

[![Ruby on Rails](https://img.shields.io/badge/Ruby_on_Rails-8.1.3-CC0000?style=flat&logo=ruby-on-rails)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat&logo=postgresql)](https://www.postgresql.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3.4-38B2AC?style=flat&logo=tailwind-css)](https://tailwindcss.com/)
[![Hotwire](https://img.shields.io/badge/Hotwire-Turbo_|_Stimulus-000000?style=flat)](https://hotwired.dev/)
[![Acessibilidade](https://img.shields.io/badge/Acessibilidade-LIBRAS-FFD700?style=flat)](https://www.gov.br/inclusao)

---

## 📌 Resumo / Abstract

### Resumo (Português)
O **PrimoQuiz** é uma plataforma web interativa desenvolvida como projeto de **Iniciação Científica**, cujo objetivo principal é promover a **acessibilidade no ensino de matemática para alunos surdos**. A aplicação foca no ensino de **Teoria dos Números** (com ênfase em números primos, Crivo de Eratóstenes, Teorema Fundamental da Aritmética e Criptografia RSA), conectando conceitos matemáticos abstratos com aplicações práticas no cotidiano tecnológico (ex.: segurança bancária e criptografia de mensagens).

A solução integra recursos de **multimodalidade e tecnologia assistiva**, incluindo interpretação em **LIBRAS (Língua Brasileira de Sinais)** via vídeo por questão, internacionalização (PT-BR / EN), design responsivo com suporte a temas claro/escuro (*Dark/Light Mode*) e respostas dinâmicas em tempo real sem recarregamento de página (*Hotwire Turbo*). O software combina metodologias de gamificação e feedback pedagógico imediato para engajar estudantes do Ensino Médio.

### Abstract (English)
**PrimoQuiz** is an interactive web platform developed as a **Scientific Initiation project** aimed at promoting **accessibility in mathematics education for deaf students**. The application focuses on teaching **Number Theory** (emphasizing prime numbers, the Sieve of Eratosthenes, the Fundamental Theorem of Arithmetic, and RSA Cryptography), connecting abstract mathematical concepts with practical real-world applications (e.g., banking security and message encryption).

The solution incorporates **multimodal features and assistive technologies**, including **Brazilian Sign Language (LIBRAS)** video support per question, internationalization (PT-BR / EN), a responsive dark/light theme UI, and real-time page updates without reloads via *Hotwire Turbo*. The software leverages gamification and immediate pedagogical feedback to increase high school student engagement.

---

## 🔬 Contexto Científico e Problematização

1. **Desafio da Inclusão na Educação Matemática**: Alunos surdos frequentemente enfrentam barreiras na aprendizagem de matemática devido à escassez de materiais didáticos digitais sinalizados em LIBRAS e à predominância de abordagens estritamente textuais.
2. **Relevância da Teoria dos Números**: A Teoria dos Números é um pilar da matemática moderna e da Ciência da Computação. O PrimoQuiz contextualiza números primos demonstrando sua utilidade na **segurança digital** (criptografia assimétrica RSA), motivando o aluno a compreender a relevância da disciplina.
3. **Engajamento por Gamificação e Feedback Pedagógico**: O software aplica técnicas de gamificação (módulos progressivos, pontuação, ranking global) alinhadas a feedbacks explicativos detalhados para cada resposta (correta ou incorreta), estimulando a autonomia e o aprendizado significativo.

---

## 🛠️ Arquitetura e Stack Tecnológica

O sistema foi arquitetado utilizando padrões modernos de desenvolvimento web focados em alta performance, manutenibilidade e baixo custo de infraestrutura:

| Camada | Tecnologia | Descrição |
|---|---|---|
| **Linguagem / Framework Backend** | Ruby 4.0.5 / Rails 8.1.3 | Arquitetura MVC com facilidade de I18n, segurança nativa e rotas RESTful. |
| **Banco de Dados** | PostgreSQL | Armazenamento relacional de usuários, módulos, questões e histórico de tentativas. |
| **Frontend & Interatividade** | Hotwire (Turbo + Stimulus) | Atualizações reativas de interface via HTML sobre HTTP, sem necessidade de SPAs complexas. |
| **Estilização & UI/UX** | Tailwind CSS | Sistema de design *dark-first* adaptativo baseado nos tokens do Notion, garantindo contraste visual e acessibilidade. |
| **Acessibilidade Multimodal** | Vídeos em LIBRAS & I18n | Player de vídeo em LIBRAS integrado e suporte a internacionalização (Português / Inglês). |
| **Suíte de Testes** | RSpec + Capybara + FactoryBot | Garantia de qualidade por meio de testes unitários de model e testes de integração. |

---

## 🗂️ Modelo de Dados

O modelo relacional do PrimoQuiz é estruturado nas seguintes entidades:

```
QuizModule (1) ──< Question (N) ──< Option (N)
                                └──< Feedback (N)
QuizModule (1) ──< QuizAttempt (N) >── User (1)
```

- **`User`**: Cadastro e autenticação segura (`has_secure_password`), perfil e histórico.
- **`QuizModule`**: Módulos didáticos sequenciais (ex.: "O que é primo?", "Crivo de Eratóstenes", "Primos e Criptografia").
- **`Question`**: Questões vinculadas aos módulos, com suporte a texto bilíngue, contexto teórico e URL do vídeo em LIBRAS.
- **`Option`**: Opções de resposta por questão.
- **`Feedback`**: Explicações pedagógicas diferenciadas para acertos e erros.
- **`QuizAttempt`**: Registro de desempenho e pontuação por usuário/módulo.

---

## 🌟 Principais Funcionalidades

- 🤟 **Suporte a LIBRAS por Questão**: Player de vídeo acessível contendo a tradução do enunciado e contexto para a Língua Brasileira de Sinais.
- 🌐 **Internacionalização (I18n)**: Suporte completo aos idiomas Português (PT-BR) e Inglês (EN).
- ⚡ **Interatividade sem Reload**: Utilização de Turbo Frames para navegação rápida e transição fluida entre questões.
- 🌓 **Tema Adaptativo (Dark / Light Mode)**: Interface visual de alto contraste configurável pelo usuário.
- 🏆 **Ranking Global e Histórico**: Sistema de classificação de alunos e estatísticas individuais para incentivar a aprendizagem.
- 🎓 **Feedbacks Pedagógicos Detalhados**: Explicação teórica imediata após a resposta de cada pergunta.

---

## 🚀 Como Executar o Projeto Localmente

### Pré-requisitos
- Ruby `>= 3.3` (Recomendado Ruby 4.x)
- Node.js `>= 20`
- PostgreSQL instalado e ativo

### Passo a Passo

```bash
# 1. Clonar o repositório
git clone https://github.com/davidonisarthur/quizz-rails-si.git
cd quizz-rails-si

# 2. Instalar dependências
bundle install

# 3. Configurar o banco de dados
rails db:create
rails db:migrate
rails db:seed

# 4. Iniciar o servidor de desenvolvimento
bin/dev # ou rails server
```

Acesse no navegador: `http://localhost:3000`

---

## 📖 Citação Acadêmica / Citation (BibTeX)

Caso utilize este software ou sua documentação em seu artigo científico ou trabalho acadêmico, utilize o formato de citação abaixo:

```bibtex
@misc{primoquiz2026,
  author       = {Arthur, Davidonis},
  title        = {PrimoQuiz: Plataforma Web Interativa e Acessível para o Ensino de Teoria dos Números a Estudantes Surdos},
  year         = {2026},
  publisher    = {GitHub},
  journal      = {Repositório de Iniciação Científica},
  howpublished = {\url{https://github.com/davidonisarthur/quizz-rails-si}}
}
```

---

*Projeto desenvolvido no âmbito de Iniciação Científica (IC).*
