require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "invalid without required fields" do
    required_fields = %i[type datetime unit server]
    required_fields.each do |field|
      event = build(:event, field => nil)
      refute event.valid?, "#{field} is not required"
    end
  end
end