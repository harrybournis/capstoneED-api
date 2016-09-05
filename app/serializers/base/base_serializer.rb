class Base::BaseSerializer < ActiveModel::Serializer

	 def attributes(*args)
  	return super unless scope[:ids_only]
  	#super.extract!(:id)
  	{ id: super[:id] }
  end
end
