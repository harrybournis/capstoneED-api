class FeelingSerializer < FeelingSerializer
	has_many :project_evaluations, serializer: Base::BaseSerializer
end
