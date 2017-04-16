require 'rails_helper'

RSpec.describe Log do

  before :each do
    @sp = create :students_project
    @entry = @sp.logs[0]
    @valid_params = valid_log_entry
    @invalid_params = invalid_log_entry
  end

  it 'is initialized successfully' do
    log = Log.new(@entry, @sp)
    expect(log).to be_truthy
  end

  describe 'success' do
    it '#project returns the project object' do
      log = Log.new(@entry, @sp)

      expect(log.project).to eq @sp.project
    end

    it '#student returns the student object' do
      log = Log.new(@entry, @sp)

      expect(log.student).to eq @sp.student
    end

    it '#save creates a new log entry in students_project.logs hash' do
      log = Log.new(@valid_params, @sp)

      expect {
        log.save
      }.to change { @sp.logs.length }
    end

    it '#save returns log object if successful' do
      log = Log.new(@valid_params, @sp)

      expect(log.save).to eq log
    end

    it '#errors returns empty if successful save' do
      log = Log.new(@valid_params, @sp)

      expect(log.save).to be_truthy
      expect(log.errors).to be_empty
    end

    it '#valid? returns true if successful save' do
      log = Log.new(@valid_params, @sp)

      expect(log.save).to be_truthy
      expect(log.valid?).to be_truthy
    end

    it '#persisted returns true after successful save' do
      log = Log.new(@valid_params, @sp)

      expect(log.persisted?).to be_falsy
      expect(log.save).to be_truthy
      expect(log.persisted?).to be_truthy
    end
  end

  describe 'Failure' do
    it '#save returns false if errors in saving' do
      log = Log.new(@invalid_params, @sp)

      expect(log.save).to be_falsy
    end

    it '#save returns false if record has already persisted' do
      log = Log.new @valid_params, @sp, true

      expect(log.save).to be_falsy
      expect(log.errors[0]).to include 'persisted'
    end

    it '#errors returns array of errors if unsuccessful save' do
      log = Log.new(@invalid_params, @sp)

      expect(log.save).to be_falsy
      expect(log.errors).to be_truthy
      expect(log.errors[:log_entry].length).to eq 1
      expect(log.errors[:log_entry][0]).to be_a String
    end

    it '#valid? returns false if unsuccessful save' do
      log = Log.new(@invalid_params, @sp)

      expect(log.save).to be_falsy
      expect(log.valid?).to be_falsy
    end
  end
end
