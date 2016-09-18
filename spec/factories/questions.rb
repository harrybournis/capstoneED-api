FactoryGirl.define do
	factory :question do
		lecturer_id { FactoryGirl.create(:lecturer).id }
		category 		{ ['question', 'comment'].sample }
		text				"Bacon ipsum dolor amet jowl shankle landjaeger t-bone porchetta pork chop frankfurter. Biltong pork chop bresaola sirloin fatback, short ribs tri-tip. Pork loin chuck strip steak frankfurter, chicken pork belly pancetta kielbasa rump tenderloin salami cupim shankle."
	end
end
