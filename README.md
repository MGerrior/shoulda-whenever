# shoulda-whenever

This gem was born out of a desire to test the schedule for tasks being scheduled with Whenever. Not to test if Whenever can generate the proper CRON schedule, but to test whether I can generate the proper `config/schedule.rb`. It turns out I can't sometimes.

## How to use this Gem

Add this to you gemfile:

```ruby
gem "shoulda-whenever", "~> 0.0.2"
```

Create a new schedule to be tested at `config/schedule.rb` (or anywhere really, but for the sake of the README, that's where it is):

```ruby
every :friday, at: "12:00 PM" do
  runner "Notifier.send_team_lunch_email"
end
```

Create a new test file for testing your schedule, perhaps something like `spec/schedule_spec.rb`:

```ruby
describe "Schedule" do
  include Shoulda::Whenever

  let(:whenever) { Whenever::JobList.new(file: File.join(Rails.root, "config", "schedule.rb").to_s) }

  it "sends out the team lunch reminder email every friday at noon" do
    expect(whenever).to schedule("Notifier.send_team_lunch_email").every(:friday).at("12:00 PM")
  end
end
```
