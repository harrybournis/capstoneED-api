class AssignmentSerializer < Base::BaseSerializer
  attributes :start_date, :end_date, :name, :unit_id
  attribute :pa_form, if: :pa_forms_any?

  def pa_form
    object.pa_forms[0]
  end

  def pa_forms_any?
    object.pa_forms.length > 0
  end
end
