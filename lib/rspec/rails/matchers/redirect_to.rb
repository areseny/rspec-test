module RSpec::Rails::Matchers
  module RedirectTo
    class RedirectTo < RSpec::Matchers::BuiltIn::BaseMatcher

      def initialize(scope, expected)
        @expected = expected
        @scope = scope
      end

      # @api private
      def matches?(_)
        match_unless_raises ActiveSupport::TestCase::Assertion do
          @scope.assert_redirected_to(@expected)
        end
      end

      # @api private
      def failure_message
        rescued_exception.message
      end

      # @api private
      def failure_message_when_negated
        "expected not to redirect to #{@expected.inspect}, but did"
      end
    end

    # Delegates to `assert_redirected_to`
    #
    # @example
    #
    #     expect(response).to redirect_to(:action => "new")
    def redirect_to(target)
      RedirectTo.new(self, target)
    end
  end
end
