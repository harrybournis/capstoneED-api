class ScoredProjectSerializer < ActiveModel::Serializer
    attributes :assignment_id, :project_name, :team_name, :description,
   :logo, :enrollment_key, :unit_id, :color, :students

    def students
      array = []
      @instance_options[:iteration].iteration_marks.each do |im|
        array << { id: im.student_id, full_name: im.student.full_name, avatar_url: im.student.avatar_url, pa_score: im.pa_score }
      end
      array
    end

    type 'project'
end
