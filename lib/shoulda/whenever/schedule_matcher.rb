module Shoulda
  module Whenever
    def schedule(task)
      ScheduleMatcher.new(task)
    end

    alias_method :schedule_rake, :schedule
    alias_method :schedule_runner, :schedule
    alias_method :schedule_command, :schedule

    class ScheduleMatcher
      attr_reader :duration, :time, :task

      def initialize(task)
        @task = task
        @duration = nil
        @time = nil
      end

      def matches?(subject)
        jobs = subject.instance_variable_get("@jobs")

        jobs = filter_jobs_by_duration(jobs)
        jobs = filter_jobs_by_time(jobs)
        jobs = filter_jobs_by_task(jobs)

        jobs.any?
      end

      def filter_jobs_by_duration(jobs)
        if duration.nil?
          jobs.values.flatten
        else
          jobs[duration]
        end
      end

      def filter_jobs_by_time(jobs)
        return jobs if time.nil?

        jobs.select { |job| job.at == time }
      end

      def filter_jobs_by_task(jobs)
        jobs.select do |job|
          job.instance_variable_get("@options")[:task] == task
        end
      end

      def every(duration)
        @duration = duration

        self
      end

      def at(time)
        @time = time

        self
      end

      def description
        [base_description, duration_description, time_description].compact.join(' ')
      end

      def failure_message
        [base_failure_message, duration_description, time_description].compact.join(' ')
      end

      def failure_message_when_negated
        [base_failure_message_when_negated, duration_description, time_description].compact.join(' ')
      end

      private

      def base_description
        "schedule \"#{ task }\""
      end

      def duration_description
        unless duration.nil?
          if duration.is_a?(String)
            "every \"#{ duration }\""
          else
            "every #{ duration.to_i } seconds"
          end
        end
      end

      def time_description
        unless time.nil?
          "at \"#{ time }\""
        end
      end

      def base_failure_message
        "expected to schedule \"#{ task }\""
      end

      def base_failure_message_when_negated
        "expected not to schedule \"#{ task }\""
      end
    end
  end
end
