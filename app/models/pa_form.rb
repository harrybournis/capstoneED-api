## A Lecturer creates a PAForm to assess students for each iteration
class PaForm < Deliverable
  include ValidationHelpers
  # Attributes
  # iteration_id  :integer
  # questions     :jsonb { question_id => question_text }
  # start_offset  :integer (start_date)
  # end_offset    :integer (deadline)

  # Associations
  belongs_to  :iteration
  has_many    :peer_assessments
  has_many    :extensions, foreign_key: :deliverable_id
  has_one     :assignment, through: :iteration
  has_many    :projects, through: :assignment
  has_many    :students_projects, through: :projects

  # Validations
  validates_presence_of   :iteration, :questions, :start_offset, :end_offset
  validate                :format_of_questions
  # validate                :start_date_is_in_the_future
  validate                :deadline_is_after_start_date

  before_validation :set_start_offset_end_offset

  # Returns only the PAForms that are available for completion now
  def self.active
    now = DateTime.now
    joins(:iteration).where("iterations.deadline < :now and \n
                              iterations.deadline > :two_months",
                              now: now, two_months: now - 2.months)
                     .select { |pa| pa.active? }
  end

  # Returns true if the current time is after the form's start_date, and
  # before the form's deadline
  def active?
    now = DateTime.now
    now >= start_date && now <= deadline
  end

  # Get the start date of the PAForm. It is calculated form the iteration's
  # deadline.
  def start_date
    return nil unless iteration.present?
    Time.at(iteration.deadline.to_i + start_offset.to_i).to_datetime
  end

  # Get the deadline of the PAForm. It is calculated form the iteration's
  # deadline.
  def deadline
    return nil unless iteration.present?
    Time.at(iteration.deadline.to_i + end_offset.to_i).to_datetime
  end

  # Get the start_date_validate variable, that will be used to calculate
  # the start offset before saving.
  def start_date=(value)
    @start_date_validate = value.to_datetime.to_i
  rescue
    nil
  end

  # Get the deadline_validate variable, that will be used to calculate
  # the start offset before saving.
  def deadline=(value)
    @deadline_validate = value.to_datetime.to_i
  rescue
    nil
  end

  # Override questions setter to receive an array and format and save it
  # in the desired format.
  #
  # @param  [Array]   questions_param The questions of the PAform as an
  #                   Array in the order they are supposed to appear.
  def questions=(questions_param)
    super nil ; return unless questions_param.is_a?(Array) && questions_param.any?
    jsonb_array = []

    questions_param.each_with_index do |elem, i|
      super nil ; return unless elem['text'].present? && elem['type_id'].present?
      jsonb_array << { 'question_id' => i + 1,
                       'text' => elem['text'],
                       'type_id' => elem['type_id'] }
    end
    super jsonb_array
  end

  # return the deadline plus the extension time if there is one for
  # a specific project if there is no extension returns just the deadline
  def deadline_with_extension_for_project(project)
    extension = Extension.where(project_id: project.id, deliverable_id: id)[0]
    if extension.present?
      Time.at(deadline.to_i + extension.extra_time).to_datetime
    else
      deadline
    end
  end

  private

  # If translates the values of start_date and deadline to start_offset
  # and end_offset. Run before validations.
  def set_start_offset_end_offset
    return unless iteration.present?

    if @deadline_validate
      self.end_offset   = @deadline_validate - iteration.deadline.to_i
    end

    if @start_date_validate
      self.start_offset = @start_date_validate - iteration.deadline.to_i
    end
  end

  # Validation of the questions format
  #
  def format_of_questions
    return unless questions.present?

    q_types = QuestionType.all.select(:id).map { |q| q.id }

    schema = Dry::Validation.JSON do
      configure do
        config.input_processor = :form
        config.type_specs = true
        config.messages = :i18n
      end

      each do
        schema do
          required(:question_id, :int).value(:int?)
          required(:text, :int).value(:str?)
          required(:type_id, :int).value(:int?, included_in?: q_types)
        end
      end
    end

    result = schema.call(questions)

    result_errors_to_active_model :questions, result
  end

  # start_date validation
  def start_date_is_in_the_future
    return if start_date.present? && start_date >= DateTime.now - 1.minute
    errors.add(:start_date, "can't be in the past")
  end

  # deadline validation
  def deadline_is_after_start_date
    return if deadline.present? && start_date.present? && deadline > start_date
    errors.add(:deadline, "can't be before the start_date")
  end
end
