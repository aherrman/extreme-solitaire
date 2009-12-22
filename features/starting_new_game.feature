Feature: starting a new game

  As a game player
  I want to start a new game
  So that I can kill some time

  Scenario: start game
    Given I am not yet playing
    When I start a new game
    Then I should start with a valid deck
