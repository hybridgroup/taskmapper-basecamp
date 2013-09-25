require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TaskMapper::Basecamp" do
  let(:tm) { TaskMapper.new(:basecamp, {:domain => 'ticketmaster.basecamphq.com', :token => '000000'}) }

  before(:each) do
    headers = {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'}
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/me.json', headers, fixture_for('project_count'), 200
    end
  end

  it { tm.should be_an_instance_of(TaskMapper) }
  it { tm.should be_a_kind_of(TaskMapper::Provider::Basecamp) }

  it "should be able to validate it's authentication" do
    pending
    @ticketmaster.valid?.should be_true
  end
end
