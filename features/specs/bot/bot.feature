Feature: sold items
  @login
  Scenario: List items
    Given um cliente com login e senha válidos
    When preencher login e senha
    Then o sistema deve realizar o login com sucesso
