Feature: #install dble
  Scenario: #install single dble in a clean environment
    Given a clean environment in all dble nodes
    Given install dble in all dble nodes
    Then Start dble in "dble-1"