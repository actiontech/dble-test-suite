Feature: install single dble

  @BLOCKER
  Scenario: install single dble in a clean environment
    Given a clean environment in all dble nodes
    Given install dble in "dble-1"
    Given replace config files in "dble-1" with command line config
    Then Start dble in "dble-1"