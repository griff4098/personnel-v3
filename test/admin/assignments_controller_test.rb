require "test_helper"

class Admin::AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    endpoints = Rails.configuration.endpoints
    stub_request(:any, /#{endpoints[:vanilla][:base_url][:internal]}.*/)
    stub_request(:any, /#{endpoints[:discourse][:base_url][:internal]}.*/)
  end

  test "should get index" do
    user_unit = create(:unit)
    create(:permission, :leader, abbr: "assignment_add", unit: user_unit)
    user = create(:user)
    create(:assignment, :leader, user: user, unit: user_unit)

    sign_in_as user
    get admin_assignments_url
    assert_response :success
  end

  test "should create assignment if unit is in scope" do
    user_unit = create(:unit)
    create(:permission, :leader, abbr: "assignment_add", unit: user_unit)
    user = create(:user)
    create(:assignment, :leader, user: user, unit: user_unit)
    subject = create(:user)
    position = create(:position)
    unit = create(:unit, parent: user_unit)
    assignment = build(:assignment, user: subject, unit: unit, position: position)

    sign_in_as user
    assert_difference("Assignment.count", 1) do
      post admin_assignments_url, params: {assignment: assignment_attributes(assignment)}
    end

    assert_redirected_to admin_assignment_url(Assignment.last)
  end

  test "should fail to create assignment if unit is not in scope" do
    user_unit = create(:unit)
    create(:permission, :leader, abbr: "assignment_add", unit: user_unit)
    user = create(:user)
    create(:assignment, :leader, user: user, unit: user_unit)
    subject = create(:user)
    position = create(:position)
    unit = create(:unit)
    assignment = build(:assignment, user: subject, unit: unit, position: position)

    sign_in_as user
    assert_difference("Assignment.count", 0) do
      post admin_assignments_url, params: {assignment: assignment_attributes(assignment)}
    end

    assert_equal "You are not authorized to perform this action.", flash[:error]
  end

  test "should end old assignment if transfer_from_unit is in scope" do
    user_unit = create(:unit)
    create(:permission, :leader, abbr: "assignment_add", unit: user_unit)
    user = create(:user)
    create(:assignment, :leader, user: user, unit: user_unit)
    subject = create(:user)
    position = create(:position)
    unit = create(:unit, parent: user_unit)
    assignment = build(:assignment, user: subject, unit: unit, position: position)

    old_unit = create(:unit, parent: user_unit)
    old_assignment = create(:assignment, user: subject, unit: old_unit)

    sign_in_as user
    post admin_assignments_url, params: {
      assignment: {
        **assignment_attributes(assignment),
        transfer_from_unit_id: old_unit.id
      }
    }

    old_assignment.reload
    assert_equal assignment.start_date, old_assignment.end_date
  end

  test "should fail to create assignment or end old assignment if transfer_from_unit is not in scope" do
    user_unit = create(:unit)
    create(:permission, :leader, abbr: "assignment_add", unit: user_unit)
    user = create(:user)
    create(:assignment, :leader, user: user, unit: user_unit)
    subject = create(:user)
    position = create(:position)
    unit = create(:unit, parent: user_unit)
    assignment = build(:assignment, user: subject, unit: unit, position: position)

    old_unit = create(:unit)
    old_assignment = create(:assignment, user: subject, unit: old_unit)

    sign_in_as user
    assert_difference("Assignment.count", 0) do
      post admin_assignments_url, params: {
        assignment: {
          **assignment_attributes(assignment),
          transfer_from_unit_id: old_unit.id
        }
      }
    end

    assert_equal "You are not authorized to perform this action.", flash[:alert]

    old_assignment.reload
    assert_nil old_assignment.end_date
  end

  private

  def assignment_attributes(assignment)
    assignment.attributes
      .symbolize_keys
      .slice(:member_id, :unit_id, :position_id, :start_date, :end_date)
  end
end
