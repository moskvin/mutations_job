# frozen_string_literal: true

require 'sidekiq'
require 'mutations'
require 'active_support/string_inquirer'

module Mutations
  class Job < Mutations::Command
    # Create a job class dynamically and perform it asynchronously
    def self.perform_async(validate: true, **args)
      job_name = "#{name}Job"

      Object.const_defined?(job_name) || Object.const_set(job_name, Class.new do
        include Sidekiq::Job

        def perform(payload)
          command_args = payload['payload']
          command_args = JSON.parse(command_args)

          klass = self.class.name.delete_suffix('Job').constantize
          payload['validate'] ? klass.run!(**command_args) : klass.run(**command_args)
        rescue JSON::ParserError
          raise Mutations::Error, "Invalid JSON payload: #{payload['payload']}"
        rescue StandardError
          raise if payload['validate']
        end
      end)

      payload = args.to_json
      job_name.constantize.perform_async({ validate:, payload: }.stringify_keys)
    end
  end
end
