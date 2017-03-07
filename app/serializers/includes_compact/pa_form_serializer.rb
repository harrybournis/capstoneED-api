class IncludesCompact::PaFormSerializer < Base::BaseSerializer
  belongs_to :iteration, serializer: Base::BaseSerializer
end
