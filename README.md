# ActiveNotifier

A unified interface for sending SMS and phone calls and handling responses with
an external API that looks a lot like ActionMailer.

There's also a Notification functionality that allows you to define all of your
notifications for a particular event and send them all out at once, or only use
one, depending on user preference.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_notifier'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_notifier

## Getting Started

Define some Messengers or Callers. These are the classes for SMS and phone
calls, respectively.

```ruby
class UserMessenger < ActiveNotifier::Messenger
  default from: '8005551234'
  event :new_message do |user, person|
    sms(to: user.phone_number, body: "#{person.name} sent you a message!")
  end

  # You can also define response handlers so your users can response directly to
  # messages from whatever channel you sent things out on.
  event :friend_request do |friend_request|
    sms(to: friend_request.to.phone_number,
        body: "#{friend_request.from.name} added you on FB4Dogs. Do you accept? YES or NO")
  end

  # If you DO define a response handler, ActiveNotifier will only send one
  # message to a particular phone number at a time. The others will get queued until
  # the user responds. Otherwise, there's no way to know WHICH thing they're
  # responding to.
  on_response_to :friend_request do |response, friend_request|
    if response == 'YES'
      friend_request.approve
    else
      friend_request.deny
    end
  end
end

class UserCaller < ActiveNotifier::Caller
  default from: '8005551234'

  event :friend_request do |friend_request|
    call(to: friend_request.to.phone_number) do |call|
      call.say "Hello, #{friend_request.to.name}. #{friend_request.from.name}
                added you on FB4Dogs. Would you like to accept? 1 for yes, 2 for no."
      call.gather timeout: 10, num_digits: 1
    end
  end

  on_response_to :friend_request do |response, friend_request|
    if response == 1
      friend_request.approve
    else
      friend_request.deny
    end
  end
```

then set up some Notifiers

```ruby
class UserNotifier < ActiveNotifier::Notifier
  notifies_on sms: UserMessenger, phone: UserCaller, email: UserMailer
end
```

Then send them out!

```ruby
# only send this via SMS and email
user.preferred_contact_methods = [:sms, :email]
UserNotifier.friend_request(user, possible_friend).for(user).deliver_later
```

You can also use the Messengers/Callers directly via a similar interface.

```ruby
UserMessenger.friend_request(user, possible_friend).deliver_later
```

`deliver_later` uses ActiveJob under the hood, so you can pass in the familiar
options like wait.

```ruby
UserMessenger.friend_request(user, possible_friend).deliver_later(wait_until: 10.minutes.from_now)
```

For the response functionality or phone calls to work, you'll need some web 
server that accepts the responses. There's one built-in to ActiveNotifier for 
Rails, but you can build your own (see the engines directory for details).

If using Rails and Twilio, just add this to your routes file:

```ruby
mount ActiveNotifier::TwilioMessenger::Engine => '/twilio_messages'
mount ActiveNotifier::TwilioCaller::Engine => '/twilio_calls'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RenovateSimply/active_notifier.

