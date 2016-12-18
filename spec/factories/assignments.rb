FactoryGirl.define do
  factory :assignment do
    start_date  { Date.today }
    end_date 	  { Date.today + 3.months+(100*rand()) }
  	description "Lorem ipsum dolor sit amet, pri in erant detracto antiopam, duis altera nostrud id eam. Feugait invenire ut vim, novum reprimique reformidans id vis, sit at quis hinc liberavisse. Eam ex sint elaboraret assueverit, sed an equidem reformidans, idque doming ut quo. Ex aperiri labores has, dolorem indoctum hendrerit has cu. At case posidonium pri."
    lecturer 		{ FactoryGirl.create(:lecturer_with_units) }
    unit 				{ lecturer.units.first }
    lecturer_id { lecturer.id }
    unit_id			{ unit.id }

    factory :assignment_with_projects do
    	projects { Array.new(2){ |i| FactoryGirl.create(:project) } }
    end
  end
end
