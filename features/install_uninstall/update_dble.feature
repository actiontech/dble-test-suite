Feature:
    Scenario: #update dble in a base environment
    Given uninstall dble in "dble-1"
    Given install dble in "dble-1"
    Then Start dble in "dble-1"
