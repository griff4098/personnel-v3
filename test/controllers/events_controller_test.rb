require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unit = create(:unit)
    create(:permission, abbr: "event_view", unit: @unit)

    @user = create(:user)
    create(:assignment, :leader, user: @user, unit: @unit)
  end

  test "should get index" do
    get events_url
    assert_response :success
  end

  test "should show event" do
    sign_in_as @user
    event = create(:event, unit: @unit)
    get event_url(event)
    assert_response :success
  end

  test "should show attendance statuses" do
    sign_in_as @user
    event = create(:event, unit: @unit)

    create(:attendance_record, event: event, attended: true)
    create(:attendance_record, event: event, attended: false, excused: true)
    create(:attendance_record, event: event, attended: false, excused: false)
    get event_url(event)

    assert_select ".attendance li", {count: 3}, "Expected 3 attendees to be listed"
    assert_select ".attendance li span", {text: "Excused", count: 1}, "Expected 1 excused attendee to be listed"
    assert_select ".attendance li span", {text: "AWOL", count: 1}, "Expected 1 AWOL attendee to be listed"
  end
end
