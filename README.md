# taskmapper-basecamp

This is the [TaskMapper][] adapter for interaction with [Basecamp Classic][]

## Setup

By default, API access is disabled on Basecamp accounts. You will have to  go
into the account page to enable it:

1. From the dashboard, click the "Account (Upgrade/Invoices)" tab in the right hand side.
2. Scroll down to the Basecamp API section. (It should be near the bottom, second-to-last.)
3. Enable it. Once it's enabled, you'll see: "The API is currently enabled for this account."

## Token

While you can use the adapter with your Basecamp username and password, it is
recommended that you use an authentication token instead. You can find your
token on the "My Info" page (at the top right corner of Basecamp, next to the
"Sign out" link).

At the bottom of that page is the "Authentication tokens" section. Click on the
"Show your tokens" link for your API token. It's the first one.

## Usage

Initialize the taskmapper-basecamp instance using your domain and either
a username/password or authentication token:

```ruby
basecamp = TaskMapper.new(
  :basecamp,
  :domain => "YOURDOMAIN.basecamphq.com",
  :token => "YOUR_TOKEN"
)

basecamp = TaskMapper.new(
  :basecamp,
  :domain => "YOURDOMAIN.basecamphq.com",
  :username => "YOUR_USERNAME",
  :password => "YOUR_PASSWORD"
)
```

## Finding Projects

You can find your own projects by using:

```ruby
projects = basecamp.projects # will return all projects
projects = basecamp.projects ["project_id", "another_project_id"]
project = basecamp.projects.find :first, "project_id"
projects = basecamp.projects.find :all, ["project_id", "another_project_id"]
```

## Finding Tickets

```ruby
tickets = project.tickets # All open tickets
tickets = project.tickets :all, :status => 'closed' # all closed tickets
ticket = project.ticket 981234
```

## Opening A Ticket

```ruby
ticket = project.ticket!(
  :title => "Content of the new ticket."
)
```

## Closing Tickets

```ruby
ticket.close
```

## Reopening Tickets

```ruby
ticket.reopen
```

## Updating Tickets

```ruby
ticket.title = "New title"
ticket.save
```

## Finding Comments

```ruby
ticket.comments # all comments for a ticket
ticket.comments 90210
```

## Creating a Comment

```ruby
ticket.comment! :body => "New Comment!"
```

## Dependencies

- rubygems
- [taskmapper][]
- [basecamp][]

## Contributors

* [Kir Shatrov](https://github.com/kirs) ([Evrone company](https://github.com/organizations/evrone))

## Contributing

The main way you can contribute is with some code! Here's how:

- Fork `taskmapper-basecamp`
- Create a topic branch: git checkout -b my_awesome_feature
- Push to your branch - git push origin my_awesome_feature
- Create a Pull Request from your branch
- That's it!

We use RSpec for testing. Please include tests with your pull request. A simple
`bundle exec rake` will run the suite. Also, please try to TomDoc your methods,
it makes it easier to see what the code does and makes it easier for future
contributors to get started.

(c) 2013 The Hybrid Group

[taskmapper]: http://ticketrb.com
[basecamp classic]: https://basecamp.com/classic
[basecamp]: https://github.com/anibalcucco/basecamp-wrapper
