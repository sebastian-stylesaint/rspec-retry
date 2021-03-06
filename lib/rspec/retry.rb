require 'rspec/retry/version'
require 'rspec_ext/rspec_ext'

module RSpec
  class Retry

    def self.default_retries
      @@default_retries || 1
    end

    def self.default_retries=(default_retries)
      @@default_retries = default_retries
    end

    def self.apply
      RSpec.configure do |config|
        config.add_setting :verbose_retry, :default => false
        config.around(:each) do |example|
          retry_count = example.metadata[:retry] || RSpec::Retry.default_retries
          retry_count.times do |i|
            if RSpec.configuration.verbose_retry?
              if i > 0
                message = "RSpec::Retry: #{RSpec::Retry.ordinalize(i + 1)} try #{@example.location}"
                message = "\n" + message if i == 1
                RSpec.configuration.reporter.message(message)
              end
            end
            @example.clear_exception
            example.run
            break if @example.exception.nil?
          end
        end
      end
    end

    # borrowed from ActiveSupport::Inflector
    def self.ordinalize(number)
      if (11..13).include?(number.to_i % 100)
        "#{number}th"
      else
        case number.to_i % 10
        when 1; "#{number}st"
        when 2; "#{number}nd"
        when 3; "#{number}rd"
        else    "#{number}th"
        end
      end
    end
  end
end

RSpec::Retry.apply
