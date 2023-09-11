# frozen_string_literal: true

require 'sidekiq'
require 'mutations'
require 'active_support/string_inquirer'

module Mutations
  class Job < Mutations::Command
    SUFFIX = 'Job'

    def self.init!
      Mutations::Job.descendants.map(&:to_job)
    end

    # Create a job class dynamically and perform it asynchronously
    def self.perform_async(validate: true, **args)
      to_job.perform_async(job_args(validate:, **args))
    end

    def self.perform_in(interval, validate: true, **args)
      to_job.perform_in(interval, job_args(validate:, **args))
    end

    def self.new_job_class(&)
      job_klass = Class.new { include Sidekiq::Job }

      job_klass.define_method(:perform) do |payload|
        command_args = payload['payload']
        command_args = JSON.parse(command_args)

        klass = self.class.name.delete_suffix("::#{SUFFIX}").constantize
        klass.run_with(validate: payload['validate'], **command_args)
      rescue JSON::ParserError
        raise Mutations::Error, "Invalid JSON payload: #{payload['payload']}"
      rescue StandardError
        yield if block_given?
        raise if payload['validate']
      end

      job_klass
    end

    def self.to_job(&)
      const_defined?(SUFFIX, false) || const_set(SUFFIX, new_job_class(&))
      "#{name}::#{SUFFIX}".constantize
    end

    def self.job_args(validate: true, **args)
      { validate:, payload: args.to_json }.stringify_keys
    end

    def self.run_with(validate:, **args)
      validate ? run!(**args) : run(**args)
    end
  end
end
