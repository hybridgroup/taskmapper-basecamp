require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Basecamp::Project" do
  before(:all) do
    headers = {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'}
    wheaders = headers.merge('Content-Type' => 'application/xml')
    @project_id = 5220065
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects.xml', headers, fixture_for('projects'), 200
      mock.get '/projects/5220065.xml', headers, fixture_for('projects/5220065'), 200
      mock.get '/projects/create.xml', headers, fixture_for('projects/create'), 200
      mock.delete '/projects/5220065.xml', headers, '', 200
      mock.put '/projects/5220065.xml', wheaders, '', 200
      mock.post '/projects.xml', wheaders, '', 201, 'Location' => '/projects/create.xml'
    end
  end
  
  before(:each) do
    @ticketmaster = TicketMaster.new(:basecamp, :token => '000000', :domain => 'ticketmaster.basecamphq.com')
    @klass = TicketMaster::Provider::Basecamp::Project
  end
  
  it "should be able to load all projects" do
    @ticketmaster.projects.should be_an_instance_of(Array)
    @ticketmaster.projects.first.should be_an_instance_of(@klass)
  end
  
  it "should be able to load projects from an array of ids" do
    @projects = @ticketmaster.projects([@project_id])
    @projects.should be_an_instance_of(Array)
    @projects.first.should be_an_instance_of(@klass)
    @projects.first.id.should == @project_id
  end
  
  it "should be able to load all projects from attributes" do
    @projects = @ticketmaster.projects(:id => @project_id)
    @projects.should be_an_instance_of(Array)
    @projects.first.should be_an_instance_of(@klass)
    @projects.first.id.should == @project_id
  end
  
  it "should be able to find a project" do
    @ticketmaster.project.should == @klass
    @ticketmaster.project.find(@project_id).should be_an_instance_of(@klass)
  end
  
  it "should be able to find a project by id" do
    @ticketmaster.project(@project_id).should be_an_instance_of(@klass)
    @ticketmaster.project(@project_id).id.should == @project_id
  end
  
  it "should be able to find a project by attributes" do
    @ticketmaster.project(:id => @project_id).id.should == @project_id
    @ticketmaster.project(:id => @project_id).should be_an_instance_of(@klass)
  end
  
  it "should be able to update and save a project" do
    @project = @ticketmaster.project(@project_id)
    @project.save.should == nil
    @project.update!(:name => 'some new name').should == true
    @project.name = 'this is a change'
    @project.save.should == true
  end
  
  it "should be able to create a project" do
    @project = @ticketmaster.project.create(:name => 'Project #1')
    @project.should be_an_instance_of(@klass)
  end

end
