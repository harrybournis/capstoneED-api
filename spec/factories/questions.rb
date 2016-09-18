FactoryGirl.define do
	factory :question do
		lecturer_id { FactoryGirl.create(:lecturer).id }
		category 		{ ['question', 'comment'].sample }
		text				"Bacon ipsum dolor amet jowl shankle landjaeger t-bone porchetta pork chop frankfurter?"
	end
end
