ActiveAdmin.register ExtendedLOA, as: "Extended LOA" do
  belongs_to :user, optional: true

  includes user: :rank

  permit_params :member_id, :posting_date, :start_date, :end_date, :return_date,
    :reason, :availability

  scope :active, default: true
  scope :all

  filter :user, collection: -> { User.for_dropdown }
  filter :start_date
  filter :end_date
  filter :reason

  index do
    selectable_column
    column :user
    column :start_date
    column :end_date
    column :reason do |extended_loa|
      extended_loa.reason.truncate 75, omission: "…"
    end
    actions
  end

  # show

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      input :user, collection: User.for_dropdown
      input :start_date
      input :end_date, label: "Planned end date"
      input :return_date, label: "Actual return date"
      input :reason
      input :availability
    end
    actions
  end
end
