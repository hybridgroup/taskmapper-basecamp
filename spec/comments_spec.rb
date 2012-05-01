require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Basecamp::Comment" do
  before(:each) do
    headers = {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'}
    gheaders = headers.merge 'Accept' => 'application/xml'
    pheaders = headers.merge 'Content-Type'=>'application/xml'
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects.xml', gheaders, fixture_for('projects'), 200
      mock.get '/projects/5220065.xml', gheaders, fixture_for('projects/5220065'), 200
      mock.get '/projects/5220065/todo_lists.xml', gheaders, fixture_for('todo_lists'), 200
      mock.get '/todo_lists/9973518/todo_items.xml', gheaders, fixture_for('todo_lists/9973518_items'), 200
      mock.get '/todo_lists/9972756/todo_items.xml', gheaders, fixture_for('todo_lists/9972756_items'), 200
      mock.get '/todo_items/62509330/comments.xml', gheaders, fixture_for('comments'), 200
      mock.get '/todo_items/62509330/comments/74197051.xml', gheaders, fixture_for('comments/74197051'), 200
      mock.get '/todo_items/62509330/comments/74197096.xml', gheaders, fixture_for('comments/74197096'), 200
      mock.post '/todo_items/62509330/comments.xml', pheaders, fixture_for('comments/74197051'), 201
    end
    @ticketmaster = TicketMaster.new(:basecamp, :domain => 'ticketmaster.basecamphq.com', :token => '000000')
    @project = @ticketmaster.projects(@project_id).first
    @ticket = @project.tickets(@ticket_id).first
    @klass = TicketMaster::Provider::Basecamp::Comment

    @project_id = 5220065
    @ticket_id = 62509330
  end

  it "should be able to load all comments" do
    @comments = @ticket.comments
    @comments.should be_an_instance_of(Array)
    @comments.first.should be_an_instance_of(@klass)
  end

  it "should be able to load all comments based on 'id's" do # lighthouse comments don't have ids, so we're faking them
    @comments = @ticket.comments([74197051, 74197096])
    @comments.should be_an_instance_of(Array)
    @comments.first.id.should == 74197051
    @comments.last.id.should == 74197096
    @comments[1].should be_an_instance_of(@klass)
  end

  it "should be able to load all comments based on attributes" do
    @comments = @ticket.comments(:commentable_id => @ticket.id)
    @comments.should be_an_instance_of(Array)
    @comments.first.should be_an_instance_of(@klass)
  end

  it "should be able to load a comment based on id" do
    @comment = @ticket.comment(74197051)
    @comment.should be_an_instance_of(@klass)
    @comment.id.should == 74197051
  end

  it "should be able to load a comment based on attributes" do
    @comment = @ticket.comment(:commentable_id => @ticket.id)
    @comment.should be_an_instance_of(@klass)
  end

  it "should return the class" do
    @ticket.comment.should == @klass
  end

  it "should be able to create a comment" do # which as mentioned before is technically a ticket update
    comment = @ticket.comment!(:body => 'hello there boys and girls')
    comment.should be_an_instance_of(@klass)
    comment.body.should_not be_nil
    comment.id.should_not be_nil
    comment.ticket_id.should_not be_nil
  end
end
