require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Basecamp::Comment" do
  let(:project_id) { 5220065 }
  let(:ticket_id) {133184178 }
  let(:tm) { TicketMaster.new(:basecamp, :domain => 'ticketmaster.basecamphq.com', :token => '000000') }
  let(:comment_class) { TicketMaster::Provider::Basecamp::Comment }
  let(:comment_id) { 74197051 }

  before(:each) do
    @headers = {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'}
    gheaders = @headers.merge 'Accept' => 'application/xml'
    pheaders = @headers.merge 'Content-Type'=>'application/xml'
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects/5220065.xml', @headers, fixture_for('projects/5220065'), 200
      mock.get '/todo_lists.xml?responsible_party=', @headers, fixture_for('todo_list_with_items'), 200
    end
    @project = tm.project(project_id)
    @ticket = @project.ticket(ticket_id)
  end

  describe "Retrieving comments" do 
    before(:each) do 
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/todo_items/133184178/comments.xml', @headers, fixture_for('comments'), 200
        mock.get '/todo_items/133184178/comments/74197051.xml', @headers, fixture_for('comments/74197051'), 200
        mock.get '/todo_items/133184178/comments/74197096.xml', @headers, fixture_for('comments/74197096'), 200
      end
    end

    context "when #comments is call to a ticket instance" do 
      subject { @ticket.comments } 
      it { should be_an_instance_of(Array) }    
      it { subject.first.should be_an_instance_of(comment_class) }
    end

    context "when #comments is call to a ticket instance with an array of id's as parameter" do 
      subject { @ticket.comments([74197051, 74197096]) }
      it { should be_an_instance_of(Array) }
      it { subject.first.should be_an_instance_of(comment_class) }
      it { subject.first.id.should be_eql(74197051) }
      it { subject.last.id.should be_eql(74197096) }
    end
  end

  it "should be able to load all comments based on 'id's" do # lighthouse comments don't have ids, so we're faking them
    pending
    @comments.should be_an_instance_of(Array)
    @comments.first.id.should == 74197051
    @comments.last.id.should == 74197096
    @comments[1].should be_an_instance_of(@klass)
  end

  it "should be able to load all comments based on attributes" do
    pending
    @comments = @ticket.comments(:commentable_id => @ticket.id)
    @comments.should be_an_instance_of(Array)
    @comments.first.should be_an_instance_of(@klass)
  end

  it "should be able to load a comment based on id" do
    pending
    @comment = @ticket.comment(74197051)
    @comment.should be_an_instance_of(@klass)
    @comment.id.should == 74197051
  end

  it "should be able to load a comment based on attributes" do
    pending
    @comment = @ticket.comment(:commentable_id => @ticket.id)
    @comment.should be_an_instance_of(@klass)
  end

  it "should return the class" do
    pending
    @ticket.comment.should == @klass
  end

  it "should be able to create a comment" do # which as mentioned before is technically a ticket update
    pending
    comment = @ticket.comment!(:body => 'hello there boys and girls')
    comment.should be_an_instance_of(@klass)
    comment.body.should_not be_nil
    comment.id.should_not be_nil
    comment.ticket_id.should_not be_nil
  end

  it "should be able to update a comment" do
    pending
    comment = @ticket.comments @comment_id
    comment.body = "updated comment"
    comment.save.should be_true
    comment.body.should == "updated comment"
  end
end
