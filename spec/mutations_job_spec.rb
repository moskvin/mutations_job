# frozen_string_literal: true

class DummyCommand < Mutations::Job
  required do
    string :name
  end
  optional do
    string :description
  end

  def execute
    puts "Run #{[name, description].compact.join(' ')}"
  end
end

RSpec.describe Mutations::Job do
  before { Sidekiq::Testing.inline! }

  it 'with validation' do
    DummyCommand.perform_async(name: 'run!', description: 'execute and validate')
  end

  it 'without validation' do
    DummyCommand.perform_async(name: 'run', description: 'just silence execute', validate: false)
  end
end
