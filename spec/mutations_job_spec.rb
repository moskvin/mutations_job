# frozen_string_literal: true

class DummyCommand < Mutations::Job
  @job_executed = false

  required do
    string :name
  end
  optional do
    string :value
    boolean :raise_error, default: false
  end

  def execute
    puts "Run #{[name, value].compact.join(' ')}"
    raise 'Execute error' if raise_error

    self.class.job_executed = true
  end

  def self.job_executed=(val)
    @job_executed = val
  end

  def self.job_executed?
    @job_executed
  end
end

RSpec.describe Mutations::Job do
  before do
    Sidekiq::Testing.inline!
    DummyCommand.job_executed = false
  end

  it 'with validation' do
    expect(DummyCommand.job_executed?).to eq(false)
    DummyCommand.perform_async(name: 'exec_and_validate', value: 'execute and validate')
    expect(DummyCommand.job_executed?).to eq(true)
  end

  it 'without validation' do
    expect(DummyCommand.job_executed?).to eq(false)
    DummyCommand.perform_async(name: 'exec_only', value: 'just execute', validate: false)
    expect(DummyCommand.job_executed?).to eq(true)
  end

  context 'with invalid inputs' do
    it 'with validation' do
      expect { DummyCommand.perform_async }.to raise_error(Mutations::ValidationException, 'Name is required')
      expect { DummyCommand.perform_async(name: 'Required name', raise_error: true) }
        .to raise_error(RuntimeError, 'Execute error')
    end

    it 'without validation' do
      expect(DummyCommand.job_executed?).to eq(false)
      DummyCommand.perform_async(validate: false)
      expect(DummyCommand.job_executed?).to eq(false)
      DummyCommand.perform_async(name: 'Required name', validate: false, raise_error: true)
      expect(DummyCommand.job_executed?).to eq(false)
    end
  end

  context 'with delayed run' do
    it 'with validation' do
      expect(DummyCommand.job_executed?).to eq(false)
      DummyCommand.perform_in(0.1, name: 'exec_and_validate', value: 'execute and validate')
      expect(DummyCommand.job_executed?).to eq(true)
    end

    it 'without validation' do
      expect(DummyCommand.job_executed?).to eq(false)
      DummyCommand.perform_in(0.1, name: 'exec_only', value: 'just execute', validate: false)
      expect(DummyCommand.job_executed?).to eq(true)
    end
  end
end
