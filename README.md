# shoulda-whenever

This gem was born out of a desire to test the schedule for tasks being scheduled with Whenever. Not to test if Whenever can generate the proper CRON schedule, but to test whether I can generate the proper `config/schedule.rb`. It turns out I can't sometimes.

## How to use this Gem

Add this to you gemfile:

```ruby
gem "shoulda-whenever", git: 'git@github.com:epigenesys/shoulda-whenever.git'
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

## Additional Filters

### Mail To

If you need to check the task output is sent to a specific email address.

```ruby
every :monday, at: "07:00 AM", mailto: "info@test.com" do
  runner "Notifier.send_good_morning_email"
end
```

```ruby
it "sends out good morning emails every monday at 7:00" do
  expect(whenever).to schedule("Notifier.send_good_morning_email").every(:monday).at("07:00 AM").with_mailto("info@test.com")
end
```

### Roles

If you need to check the task is set for specific roles.

```ruby
every :monday, at: "07:00 AM", roles: [:web] do
  runner "Notifier.send_good_morning_email"
end
```

```ruby
it "sends out good morning emails every monday at 7:00 on web servers" do
  expect(whenever).to schedule("Notifier.send_good_morning_email").every(:monday).at("07:00 AM").with_roles([:web])
end
```
