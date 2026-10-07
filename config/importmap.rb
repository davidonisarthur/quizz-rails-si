# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@mediapipe/tasks-vision", to: "https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@1.1.0/+esm"
pin_all_from "app/javascript/gesture_recognition", under: "gesture_recognition"
