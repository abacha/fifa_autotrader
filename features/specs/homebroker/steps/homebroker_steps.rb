# frozen_string_literal: true

Dado('um cliente com login e senha válidos') do
  visit '/'
end

Quando('preencher login e senha') do
  @page.call(MainPage).go
end

Entao('o sistema deve realizar o login com sucesso') do
end

Dado('um cliente logado') do
  visit '/'
  @page.call(LoginPage).go
end
