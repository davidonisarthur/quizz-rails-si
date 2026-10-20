# PrimoQuiz

[![Ruby on Rails](https://img.shields.io/badge/Ruby_on_Rails-8.1.3-CC0000?style=flat&logo=ruby-on-rails)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat&logo=postgresql)](https://www.postgresql.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4-38B2AC?style=flat&logo=tailwind-css)](https://tailwindcss.com/)
[![Hotwire](https://img.shields.io/badge/Hotwire-Turbo_|_Stimulus-000000?style=flat)](https://hotwired.dev/)
[![Acessibilidade](https://img.shields.io/badge/Acessibilidade-LIBRAS-005236?style=flat)](https://www.gov.br/inclusao)

Plataforma web bilíngue e acessível para o ensino de Matemática e Computação, desenvolvida em um projeto de Iniciação Científica da UTFPR, sob orientação da Prof.ª Dr.ª Renata da Silva Dessbesel e em coautoria com o Prof. Renan de Bastos Andrade.

## Demonstração

<video src="docs/media/video_docs.mp4" controls preload="metadata" width="100%">
  Seu navegador não suporta vídeo HTML5. Baixe o arquivo pelo link abaixo.
</video>

[Assistir ou baixar a demonstração em vídeo](docs/media/video_docs.mp4).

> O arquivo de demonstração está versionado em `docs/media/video_docs.mp4`. Em hospedagens que não renderizam a tag `<video>`, o link direto continua disponível.

## Visão geral

O PrimoQuiz foi concebido para reduzir barreiras de acesso a conteúdos de Matemática e Computação. A plataforma une quizzes progressivos, materiais de estudo, feedback pedagógico e recursos de Libras, preservando uma navegação simples para estudantes e um fluxo de autoria controlado para professores.

O conteúdo inicial trabalha Teoria dos Números, números primos, lógica e criptografia. A estrutura, porém, permite que professores criem novos quizzes e conteúdos de estudo para turmas específicas sem alterar o código da aplicação.

### Objetivos

- oferecer atividades de aprendizagem em Português e Inglês;
- disponibilizar apoio em Libras por avatar VLibras e vídeos gravados;
- permitir que docentes criem, publiquem e distribuam seus próprios materiais;
- manter o processamento do protótipo de visão computacional inteiramente no navegador;
- registrar tentativas e disponibilizar informações de progresso para alunos e docentes.

## Funcionalidades

### Para estudantes

- **Percurso de quizzes:** módulos padrão da plataforma e atividades liberadas por sequência de aprendizagem.
- **Feedback pedagógico após cada resposta:** a tela mostra a alternativa escolhida, o gabarito quando necessário e a explicação cadastrada pelo professor.
- **Perfil de aprendizagem:** progresso por módulo, melhor resultado, última tentativa, módulos pendentes e progresso em conteúdos de estudo.
- **Área de estudo:** conteúdos guiados sobre Matemática e Computação, incluindo o tema introdutório da Máquina de Turing.
- **Internacionalização:** interface e conteúdos disponíveis em PT-BR e EN.
- **Tema claro/escuro e navegação responsiva:** interface adaptada para desktop e dispositivos móveis, com foco visível e alvos de toque adequados.

### Recursos de acessibilidade e Libras

- **Modo Libras:** integra o avatar VLibras para traduzir enunciados, contextos e trechos de estudo.
- **Vídeos gravados hospedados na plataforma:** questões e conteúdos de estudo aceitam MP4, WebM ou OGG de até 150 MB via Active Storage; não dependem de links do YouTube.
- **Player acessível:** os vídeos são abertos em modal com controles nativos, foco gerenciado e suporte a teclado.
- **Interface bilíngue e responsiva:** os recursos são preservados nos fluxos de quiz, estudo e feedback.

### Área do professor

A área do professor não é apenas uma rota oculta: ela é protegida por papel de usuário e por verificações de autoria no servidor.

- **Painel docente:** apresenta número de turmas, alunos, materiais publicados, rascunhos e um próximo passo contextual.
- **Gestão de turmas:** criação e exclusão de turmas; inclusão e remoção de estudantes pelo e-mail cadastrado.
- **Autoria de quizzes:** criação, edição, publicação, pré-visualização e exclusão de quizzes próprios.
- **Editor de questões:** alternativas PT/EN, contexto, resposta correta, feedback para acerto e erro, publicação, duplicação e reordenação de questões.
- **Autoria de conteúdos de estudo:** editor rico com Action Text/Trix, anexos, versão em Português e Inglês, resumo, vídeo em Libras e vínculo opcional com um quiz.
- **Visibilidade por audiência:** cada quiz ou conteúdo pode ser público ou restrito às turmas do próprio professor. Os conteúdos padrão da plataforma permanecem disponíveis como base comum.
- **Atribuição por turma:** quizzes e conteúdos de estudo podem ser liberados para uma ou mais turmas; apenas estudantes matriculados recebem acesso ao material restrito.
- **Relatórios de quizzes:** total de tentativas, estudantes participantes, média de acertos e desempenho por questão, com filtro por turma.
- **Uploads diretos protegidos:** somente professor ou administrador pode iniciar o envio direto de vídeos para o Active Storage.

### Acesso docente e administração

- estudantes podem enviar uma solicitação de acesso docente pelo perfil;
- administradores aprovam ou recusam solicitações pendentes;
- administradores podem emitir convites de uso único para um e-mail específico; o convite expira em sete dias;
- usuários têm os papéis `student`, `teacher` e `admin`; as autorizações são verificadas no backend.

### Laboratório de visão computacional

O laboratório é um protótipo técnico para futuras práticas de Libras. Ele usa **MediaPipe Tasks Vision** no navegador para:

- abrir e encerrar a webcam corretamente;
- detectar os 21 landmarks de uma mão e desenhar suas conexões sobre o vídeo;
- analisar somente relações geométricas normalizadas, sem usar coordenadas absolutas em pixels;
- identificar a configuração de teste `gesture_01` após estabilização temporal de múltiplos frames;
- apresentar feedback de enquadramento e de condições da mão;
- processar vídeo e landmarks localmente: nenhuma imagem da webcam é enviada ao servidor.

`gesture_01` é somente uma configuração técnica. Ela não representa nem avalia um sinal real de Libras nesta versão.

## Fluxo de conteúdo e permissões

```text
Administrador
  ├── aprova solicitação docente
  └── gera convite docente

Professor
  ├── cria turmas ──> matricula estudantes
  ├── cria quizzes ──> cria questões, feedbacks e vídeos em Libras
  ├── cria conteúdos de estudo ──> texto rico, anexos e vídeos em Libras
  └── atribui quizzes/conteúdos às próprias turmas

Estudante matriculado
  ├── visualiza materiais públicos e os atribuídos às suas turmas
  ├── responde quizzes e recebe feedback imediato
  └── acompanha tentativas e progresso no perfil
```

## Modelo de dados

```text
User (student | teacher | admin)
  ├──< QuizAttempt ──< QuizResponse >── Question >── QuizModule
  ├──< ClassroomEnrollment >── Classroom (teacher)
  ├──< TeacherAccessRequest
  └──< StudyProgress

QuizModule ──< Question ──< Option
                       └──< Feedback
QuizModule ──< ModuleAssignment >── Classroom

StudyModule ──< StudyModuleAssignment >── Classroom
```

Principais entidades:

- **`QuizModule`**: módulo de quiz público, padrão da plataforma ou restrito a turmas.
- **`Question`**, **`Option`** e **`Feedback`**: enunciado, alternativas e devolutivas pedagógicas bilíngues.
- **`QuizAttempt`** e **`QuizResponse`**: desempenho final e respostas individuais para perfil e relatórios.
- **`Classroom`** e **`ClassroomEnrollment`**: organização das turmas e matrícula exclusiva de estudantes.
- **`StudyModule`**: conteúdo editorial rico, com visibilidade, vínculo opcional com quiz e vídeo em Libras.
- **`TeacherAccessRequest`** e **`TeacherInvitation`**: governança para concessão do papel docente.

## Arquitetura e stack

| Camada | Tecnologia | Uso no projeto |
|---|---|---|
| Backend | Ruby 4.0.5 e Rails 8.1.3 | MVC, rotas REST, I18n, autenticação e autorização por papel. |
| Banco de dados | PostgreSQL | Dados de usuários, turmas, conteúdo, tentativas e respostas. |
| Frontend | Hotwire (Turbo + Stimulus) | Navegação fluida, Turbo Frames no quiz e controladores de interface. |
| Estilos | Tailwind CSS 4 | Tokens visuais, tema claro/escuro e layout responsivo. |
| Conteúdo rico | Action Text/Trix + Active Storage | Editor editorial, anexos e armazenamento dos vídeos enviados à plataforma. |
| Acessibilidade | VLibras + vídeos locais | Avatar de Libras e mídia gravada associada a questões e estudos. |
| Visão computacional | MediaPipe Tasks Vision | Landmarks de mão processados inteiramente no navegador. |
| Qualidade | RSpec, Capybara, FactoryBot e SimpleCov | Testes de modelos, requisições, rotas e jornadas end-to-end. |

## Como executar localmente

### Pré-requisitos

- Ruby `4.0.5` (ou uma versão compatível definida pelo projeto);
- PostgreSQL em execução;
- Node.js `20+` para ferramentas de frontend;
- um navegador moderno para VLibras, webcam e testes de sistema.

### Instalação

```bash
git clone https://github.com/davidonisarthur/quizz-rails-si.git
cd quizz-rails-si

# Instala dependências e prepara o banco.
bin/setup --skip-server

# Carrega os módulos e questões padrão da plataforma.
bin/rails db:seed

# Inicia Rails e o watcher do Tailwind.
bin/dev
```

Abra `http://localhost:3000/pt-BR`.

Para recriar o banco localmente, use `bin/setup --reset`. Para configurar uma conta existente como docente somente em desenvolvimento, pode-se executar:

```bash
TEACHER_EMAIL=professor@exemplo.com bin/rails db:seed
```

## Testes e qualidade

```bash
# Suíte completa (modelos, requisições, rotas e jornadas de sistema)
bundle exec rspec

# Pipeline local: setup, estilo, auditorias, testes e validação das seeds
bin/ci
```

A execução mais recente da suíte contém **232 exemplos, 0 falhas**, com **100,00% de cobertura de linhas** e **97,73% de cobertura de ramos** pelo SimpleCov. A suíte cobre, entre outros fluxos, matrícula em turmas, visibilidade por audiência, autoria e exclusão de conteúdo, progresso do aluno, Libras, upload de vídeo, controle de acesso e jornadas end-to-end de aluno e professor.

## Produção e operação segura

Antes do deploy, defina o domínio permitido e a senha do PostgreSQL:

```bash
APP_HOST=quiz.exemplo.com
APP_HOSTS=quiz.exemplo.com,www.quiz.exemplo.com
QUIZZ_RAILS_DATABASE_PASSWORD=uma-senha-segura
```

Em produção, a aplicação exige HTTPS, restringe os hosts a `APP_HOSTS`/`APP_HOST` e utiliza serviços de cache, fila e cabo do Rails. O armazenamento de mídia está configurado como disco local por padrão; para produção com múltiplas instâncias, configure um serviço persistente compatível com Active Storage, como S3, antes de disponibilizar vídeos.

Boas práticas operacionais:

- configure backup externo do PostgreSQL e teste restaurações;
- armazene `RAILS_MASTER_KEY` e credenciais somente no provedor de deploy;
- crie ou promova o primeiro administrador apenas em terminal autenticado de produção:

  ```bash
  TARGET_EMAIL=admin@exemplo.com TARGET_ROLE=admin bin/rails access:grant_role
  ```

- não exponha tarefas de papel de usuário, chaves ou senhas por rotas públicas.

## Citação acadêmica

```bibtex
@misc{primoquiz2026,
  author       = {Arthur Davidonis and Renata da Silva Dessbesel and Renan de Bastos Andrade},
  title        = {PrimoQuiz: Plataforma Web Interativa e Acessível para o Ensino de Matemática e Computação},
  year         = {2026},
  publisher    = {GitHub},
  howpublished = {\url{https://github.com/davidonisarthur/quizz-rails-si}}
}
```

---

Projeto desenvolvido no âmbito de Iniciação Científica da UTFPR.
