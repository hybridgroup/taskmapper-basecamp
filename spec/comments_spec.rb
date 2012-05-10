require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TaskMapper::Provider::Basecamp::Comment do
  let(:project_id) { 5220065 }
  let(:ticket_id) {133184178 }
  let(:tm) { TaskMapper.new(:basecamp, :domain => 'ticketmaster.basecamphq.com', :token => '000000') }
  let(:comment_class) { TaskMapper::Provider::Basecamp::Comment }
  let(:comment_id) { 74197051 }

  before(:each) do
    @headers = {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'}
    gheaders = @headers.merge 'Accept' => 'application/xml'
    
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

    context "when #comments is call to a ticket instance with an array of id's as parameters" do 
      subject { @ticket.comments([74197051, 74197096]) }
      it { should be_an_instance_of(Array) }
      it { subject.first.should be_an_instance_of(comment_class) }
      it { subject.first.id.should be_eql(74197051) }
      it { subject.last.id.should be_eql(74197096) }
    end

    context "when #comments is call to a ticket instance with comments attributes as parameters" do 
      subject { @ticket.comments(:id => comment_id) }
      it { should be_an_instance_of(Array) }
      it { subject.first.should be_an_instance_of(comment_class) }
      it { subject.first.id.should be_eql(comment_id) }
    end
  end

  describe "Retrieve a single comment from a ticket" do 
    before(:each) do 
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/todo_items/133184178/comments.xml', @headers, fixture_for('comments'), 200
        mock.get '/todo_items/133184178/comments/74197051.xml', @headers, fixture_for('comments/74197051'), 200
      end
    end

    context "when #comment is call with a comment id" do 
      subject { @ticket.comment(comment_id) }
      it { should be_an_instance_of(comment_class) }
      it { subject.id.should be_eql(comment_id) }
    end

    context "when #comment is call with an attribute" do 
      subject { @ticket.comment(:id => comment_id) }
      it { should be_an_instance_of(comment_class) }
      it { subject.id.should be_eql(comment_id) }
    end
  end

  describe "Create and update a comment for a ticket" do 
    before(:each) do 
      pheaders = @headers.merge 'Content-Type'=>'application/xml'
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/todo_items/133184178/comments/74197051.xml', @headers, fixture_for('comments/74197051'), 200
        mock.get '/todo_items/133184178/comments.xml', @headers, fixture_for('comments'), 200
        mock.put '/todo_items/133184178/comments/74197051.xml', @headers, '', 200
        mock.post '/todo_items/133184178/comments.xml', pheaders, fixture_for('comments/74197051'), 200
      end
    end

    context "when a comment is changed and then called the #save on it" do 
      it do 
        comment = @ticket.comment(comment_id) 
        comment.body = "updated comment"
        comment.save.should be_true
        comment.body.should be_eql("updated comment")
      end
    end

    context "when #comment! is call" do 
      subject { @ticket.comment!(:body => 'hello there boys and girls') }
      it { should be_an_instance_of(comment_class) }
      it { subject.body.should_not be_nil }
      it { subject.id.should_not be_nil }
      it { subject.ticket_id.should_not be_nil }
    end
  end

end
