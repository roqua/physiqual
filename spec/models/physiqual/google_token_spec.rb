module Physiqual
  require 'rails_helper'
  require 'shared_examples_for_tokens'
  
  describe GoogleToken do
    it_behaves_like 'a token'
  end
end
