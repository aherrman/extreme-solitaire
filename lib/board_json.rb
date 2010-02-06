require 'json'
require 'solitaire_board'

class Card
  def to_json(*a)
    {
      'json_class' => self.class.name,
      'value' => @value,
      'suit' => @suit
    }.to_json(*a)
  end

  def self.json_create(o)
    Card.get o['value'], o['suit'].to_sym
  end
end

class StackOfCards
  def to_json(*a)
    {
      'json_class' => self.class.name,
      'cards' => @cards
    }.to_json(*a)
  end

  def self.json_create(o)
    StackOfCards.new o['cards']
  end
end

class Tableau
  def to_json(*a)
    {
      'json_class' => self.class.name,
      'cards' => @cards,
      'hidden' => @hidden_cards
    }.to_json(*a)
  end

  def self.json_create(o)
    Tableau.new o['hidden'], o['cards']
  end
end

class Foundation
  def to_json(*a)
    {
      'json_class' => self.class.name,
      'suit' => suit,
      'cards' => @cards
    }.to_json(*a)
  end

  def self.json_create(o)
    Foundation.new o['cards'], eval(":#{o['suit']}")
  end
end

class SolitaireBoard
  def to_json(*a)
    {
      'json_class' => self.class.name,
      'state' => to_state_hash
    }.to_json(*a)
  end

  def self.json_create(o)
    state = o['state']
    converted_state = {}

    # Keys from json are strings, but the state array uses symbols.
    state.keys.each { |key|
      converted_state[key.to_sym] = state[key]
    }

    SolitaireBoard.new converted_state
  end
end
