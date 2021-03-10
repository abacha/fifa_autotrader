# frozen_string_literal: true

Dado('um cliente com login e senha válidos') do
  visit '/'
end

Quando('preencher login e senha') do
  MainPage.new.go
end
