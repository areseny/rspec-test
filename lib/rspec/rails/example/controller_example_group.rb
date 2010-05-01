require 'action_controller'
require 'webrat'

module ControllerExampleGroupBehaviour
  extend ActiveSupport::Concern

  module AttributeReaders
    extend ActiveSupport::Concern
    attr_reader :controller

    module ClassMethods
      def controller_class
        describes
      end
    end
  end

  included do
    extend  Rspec::Rails::SetupAndTeardownAdapter
    include Rspec::Rails::TestUnitAssertionAdapter
    include ActionController::TestCase::Behavior
    include AttributeReaders
    include Rspec::Rails::ViewRendering
    include Webrat::Matchers
    include Webrat::Methods
    include Rspec::Matchers
    before do
      @routes = ::Rails.application.routes
      ActionController::Base.allow_forgery_protection = false
    end
  end

  Rspec.configure do |c|
    c.include self, :example_group => {
      :describes => lambda {|described| described < ActionController::Base }
    }
  end
end
