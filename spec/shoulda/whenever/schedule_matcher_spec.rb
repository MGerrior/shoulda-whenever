require "spec_helper"
require "whenever"
require "shoulda/whenever/schedule_matcher"
require "rspec/matchers/fail_matchers"
require "active_support/duration"

describe Shoulda::Whenever::ScheduleMatcher do
  include Shoulda::Whenever
  include RSpec::Matchers::FailMatchers

  let(:whenever) { Whenever::JobList.new(string: schedule_string) }

  describe "#description" do
    context "basic schedule check" do
      it "includes the task being scheduled" do
        expect(described_class.new("rake:every:10:minutes").description).to eq("schedule \"rake:every:10:minutes\"")
      end
    end

    context "with a mailto" do
      it "includes the mailto under which the task is being scheduled" do
        expect(
          described_class.new("rake:every:10:minutes")
            .every(Whenever::NumericSeconds.seconds(10, "minutes"))
            .with_mailto('test@info.com')
            .description
        ).to eq("schedule \"rake:every:10:minutes\" with_mailto \"test@info.com\" every 600 seconds")
      end
    end

    context "with a duration" do
      it "includes the duration at which the task is being scheduled" do
        expect(
          described_class.new("rake:every:10:minutes")
          .every(Whenever::NumericSeconds.seconds(10, "minutes"))
                         .description
        ).to eq("schedule \"rake:every:10:minutes\" every 600 seconds")
      end
    end

    context "with a time to run" do
      it "includes the time at which the task is scheduled to run" do
        expect(
          described_class.new("rake:every:10:minutes")
                         .at("12:00 PM")
                         .description
        ).to eq("schedule \"rake:every:10:minutes\" at \"12:00 PM\"")
      end
    end

    context "with a cron schedule" do
      it "includes the schedule" do
        expect(
          described_class.new("rake:every:1:day:at:noon")
                         .every("0 0 27-31 * *")
                         .description
        ).to eq("schedule \"rake:every:1:day:at:noon\" every \"0 0 27-31 * *\"")
      end
    end

    context "with a symbol schedule" do
      it "includes the schedule" do
        expect(
          described_class.new("rake:every:1:day:at:noon")
                         .every(:friday)
                         .description
        ).to eq("schedule \"rake:every:1:day:at:noon\" every \"friday\"")
      end
    end

    context "with a role" do
      it "includes the role" do
        expect(
          described_class.new("rake:every:day").with_role(:app).description
        ).to eq("schedule \"rake:every:day\" with \"app\" role(s)")
      end
    end

    context "with multiple roles" do
      it "includes the roles" do
        expect(
          described_class.new("rake:every:day").with_roles([:app, :database, :redis]).description
        ).to eq("schedule \"rake:every:day\" with \"app\", \"database\", \"redis\" role(s)")
      end
    end
  end

  context "a task that is not scheduled" do
    let(:schedule_string) { "" }

    it "passes" do
      expect(whenever).not_to schedule("MyTask.run")
    end

    it "fails" do
      expect {
        expect(whenever).to schedule("MyTask.run")
      }.to fail_with("expected to schedule \"MyTask.run\"")
    end
  end

  context "a task that is scheduled" do
    let(:schedule_string) do
      <<-SCHEDULE
        every 3.hours do
          rake "rake:every:3:hours"
        end
      SCHEDULE
    end

    it "passes" do
      expect(whenever).to schedule("rake:every:3:hours")
    end

    it "fails" do
      expect {
        expect(whenever).not_to schedule("rake:every:3:hours")
      }.to fail_with("expected not to schedule \"rake:every:3:hours\"")
    end
  end

  context "a task that is scheduled with a certain mailto" do
    let(:schedule_string) do
      <<-SCHEDULE
        every 3.hours, mailto: 'test@info.com' do
          rake "rake:every:3:hours"
        end
      SCHEDULE
    end

    it "passes" do
      expect(whenever).to schedule("rake:every:3:hours").every(Whenever::NumericSeconds.seconds(3, "hours")).with_mailto('test@info.com')
    end
     it "fails" do
       expect {
         expect(whenever).not_to schedule("rake:every:3:hours").every(Whenever::NumericSeconds.seconds(3, "hours")).with_mailto('test@info.com')
       }.to fail_with("expected not to schedule \"rake:every:3:hours\" with_mailto \"test@info.com\" every 10800 seconds")
     end
  end

  context "a task that is scheduled after a certain duration" do
    let(:schedule_string) do
      <<-SCHEDULE
        every 3.hours do
          rake "rake:every:3:hours"
        end
      SCHEDULE
    end

    it "passes" do
      expect(whenever).to schedule("rake:every:3:hours").every(Whenever::NumericSeconds.seconds(3, "hours"))
    end
     it "fails" do
       expect {
         expect(whenever).not_to schedule("rake:every:3:hours").every(Whenever::NumericSeconds.seconds(3, "hours"))
       }.to fail_with("expected not to schedule \"rake:every:3:hours\" every 10800 seconds")
     end
  end

  context "a task that is scheduled to run at a certain time" do
    let(:schedule_string) do
      <<-SCHEDULE
        every 1.day, at: "12:00 PM" do
          rake "rake:every:day:at:noon"
        end
      SCHEDULE
    end

    it "passes" do
      expect(whenever).to schedule("rake:every:day:at:noon").every(Whenever::NumericSeconds.seconds(1, "day")).at("12:00 PM")
    end

    it "fails" do
      expect {
        expect(whenever).not_to schedule("rake:every:day:at:noon").every(Whenever::NumericSeconds.seconds(1, "day")).at("12:00 PM")
      }.to fail_with("expected not to schedule \"rake:every:day:at:noon\" every 86400 seconds at \"12:00 PM\"")
    end
  end

  context "a task that is scheduled for a certain day" do
    let(:schedule_string) do
      <<-SCHEDULE
        every :friday do
          rake "rake:every:friday"
        end
      SCHEDULE
    end

    it "passes" do
      expect(whenever).to schedule("rake:every:friday").every(:friday)
    end

    it "fails" do
      expect {
        expect(whenever).not_to schedule("rake:every:friday").every(:friday)
      }.to fail_with("expected not to schedule \"rake:every:friday\" every \"friday\"")
    end
  end

  context "a task that is scheduled with cron syntax" do
    let(:schedule_string) do
      <<-SCHEDULE
        every '0 0 27-31 * *'  do
          rake "rake:end:of:month"
        end
      SCHEDULE
    end

    it "passes" do
      expect(whenever).to schedule("rake:end:of:month").every("0 0 27-31 * *")
    end

    it "fails" do
      expect {
        expect(whenever).not_to schedule("rake:end:of:month").every("0 0 27-31 * *")
      }.to fail_with("expected not to schedule \"rake:end:of:month\" every \"0 0 27-31 * *\"")
    end
  end

  context "a task that is scheduled for a certain role" do
    let(:schedule_string) do
      <<-SCHEDULE
        every 10.minutes, roles: [:app] do
          rake "rake:every:10:minutes"
        end
      SCHEDULE
    end

    it "passes" do
      expect(whenever).to schedule("rake:every:10:minutes").with_role(:app)
    end

    it "fails" do
      expect {
        expect(whenever).not_to schedule("rake:every:10:minutes").with_role(:app)
      }.to fail_with("expected not to schedule \"rake:every:10:minutes\" with \"app\" role(s)")
    end
  end

  context "a task that is scheduled for multiple roles" do
    let(:schedule_string) do
      <<-SCHEDULE
        every 10.minutes, roles: [:app, :database] do
          rake "rake:every:10:minutes"
        end
      SCHEDULE
    end

    it "passes" do
      expect(whenever).to schedule("rake:every:10:minutes").with_roles([:app, :database])
    end

    it "fails" do
      expect {
        expect(whenever).not_to schedule("rake:every:10:minutes").with_roles([:app, :database])
      }.to fail_with("expected not to schedule \"rake:every:10:minutes\" with \"app\", \"database\" role(s)")
    end
  end
end
