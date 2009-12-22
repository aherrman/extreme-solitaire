require File.join(File.dirname(__FILE__), "spec_helper")
  describe Card do
    context "creating a new card" do
      it "should successfully create valid cards" do
        Card::VALID_SUITS.each { |suit|
          Card::VALID_VALUES.each { |val|
            c = Card.new val, suit
          }
        }
      end

      it "should raise an error if created with an invalid value" do
        lambda{Card.new(15,:hearts)}.should raise_error(RuntimeError)
      end

      it "should raise and error if created with an invalid suit" do
        lambda{Card.new(10,:foo)}.should raise_error(RuntimeError)
      end

  end
end
