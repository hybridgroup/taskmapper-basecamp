# ticketmaster-basecamp

This is the provider for interaction with [basecamp](http://www.basecamphq.com) using [ticketmaster](http://ticketrb.com)

# Basecamp Setup

Basecamp's API access is disabled by default on their accounts. You will have to go to the account page and enable it.

1. From the dashboard, click the "Account (Upgrade/Invoices)" tab in the right hand side.
2. Scroll down to the Basecamp API section. (It should be near the bottom, second-to-last.)
3. Enable it. Once it's enabled, you'll see: "The API is currently enabled for this account."

## Token

It is recommended that you use the authentication token instead of a username and password to authenticate with basecamp. The token can be found from the "My Info" link at the top right hand corner next to the "Sign out" link.

At the bottom of that page is the "Authentication tokens" section. Click on the "Show your tokens" link for your API token. It's the first one.

# Usage

Initialize the basecamp ticketmaster instance using a token or username and password:

    basecamp = TicketMaster.new(:basecamp, :domain => 'yourdomain.basecamphq.com', :token => 'abc000...')
    basecamp = TicketMaster.new(:basecamp, :domain => 'yourdomain.basecamphq.com', :username => 'you', :password => 'pass')

## Find projects

    projects = basecamp.projects
    project = basecamp.project(id)

## Find tickets

Since basecamp does not have the conventional "tickets", ticketmaster-basecamp considers a TodoItem as a ticket, but will prepend the TodoList's title to the TodoItem's title.
    tickets = project.tickets
    ticket = project.ticket(<todoitem_id>)

## Find comments

   comments = ticket.comments

## More

For more usage information, see [ticketmaster](http://github.com/hybridgroup/ticketmaster). This provider should implement all the ticketmaster functionality. If it does not, please notify us.

## Contributions

* [Kir Shatrov](https://github.com/kirs) ([Evrone company](https://github.com/organizations/evrone))

Thanks for using ticketmaster!

### Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 HybridGroup. See LICENSE for details.