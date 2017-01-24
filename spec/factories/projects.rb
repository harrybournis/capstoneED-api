FactoryGirl.define do
  factory :project do
    sequence(:project_name) { |n| "Project #{n}" }
    sequence(:team_name) { |n| "The xmen#{n}" }
    logo nil
    enrollment_key { SecureRandom.hex }
    description "Lorem ipsum dolor sit amet, pri in erant detracto antiopam, duis altera nostrud id eam. Feugait invenire ut vim, novum reprimique reformidans id vis, sit at quis hinc liberavisse. Eam ex sint elaboraret assueverit, sed an equidem reformidans, idque doming ut quo. Ex aperiri labores has, dolorem indoctum hendrerit has cu. At case posidonium pri."
    association :assignment, factory: :assignment
    unit_id { assignment.unit.id if assignment }

    factory :project_with_logo do
    	logo "https://robohash.org/sitsequiquia.png?size=300x300"
    end
  end
end
