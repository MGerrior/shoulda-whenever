module Shoulda
  module Whenever
    def schedule(task)
      ScheduleMatcher.new(task)
    end

    alias_method :schedule_rake, :schedule
    alias_method :schedule_runner, :schedule
    alias_method :schedule_command, :schedule

    class ScheduleMatcher
      attr_reader :duration,
                  :time,
                  :task,
                  :failure_message,
                  :failure_message_when_negated

      def initialize(task)
        @task = task
        @duration = nil
        @time = nil
      end

      def matches?(subject)
        jobs = subject.instance_variable_get("@jobs")

        if duration.nil?
          jobs.any? do |time, scheduled_jobs|
            scheduled_jobs.any? do |job|
              job.instance_variable_get("@options")[:task] == task
            end
          end
        else
          scheduled_jobs = jobs.fetch(duration, [])

          scheduled_jobs.any? do |job|
            job.instance_variable_get("@options")[:task] == task
          end
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

      private

      def base_description
        "schedule \"#{ task }\""
      end

      def duration_description
        unless @duration.nil?
          if @duration.is_a?(String)
            "every \"#{ @duration }\""
          else
            "every #{ @duration.to_i } seconds"
          end
        end
      end

      def time_description
        unless @time.nil?
          "at \"#{ @time }\""
        end
      end
    end
  end
end
