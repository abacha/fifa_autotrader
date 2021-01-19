# frozen_string_literal: true

Dado('um cliente com login e senha válidos') do
  visit '/'
end

Quando('preencher login e senha') do
  @page.call(MainPage).go
  wait_for_pageload
end

Entao('o sistema deve realizar o login com sucesso') do
  wait_for_pageload
end

Dado('um cliente logado') do
  visit '/'
  @page.call(LoginPage).go
end
