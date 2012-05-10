require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TaskMapper::Provider::Basecamp::Project do

  before(:all) do 
    @headers =  {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'}
    @wheaders = @headers.merge('Content-Type' => 'application/xml') 
  end

  let(:tm) { TaskMapper.new(:basecamp, :token => '000000', :domain => 'ticketmaster.basecamphq.com') }
  let(:project_class) { TaskMapper::Provider::Basecamp::Project }
  let(:project_id) { 5220065 }

  describe "Retrieving projects" do 
    before(:each) do 
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/projects.xml', @headers, fixture_for('projects'), 200
        mock.get '/projects/5220065.xml', @headers, fixture_for('projects/5220065'), 200
      end
    end

    context "when calling #projects" do 
      subject { tm.projects }
      it { subject.should be_an_instance_of(Array) }
      it { subject.first.should be_an_instance_of(project_class) }
    end

    context "when calling #projects using an array of id's" do 
      subject { tm.projects([project_id]) }
      it { subject.should be_an_instance_of(Array) }
      it { subject.first.should be_an_instance_of(project_class) }
      it { subject.first.id.should be_eql(project_id) }
    end

    context "when calling #projects with a hash of project attributes" do 
      subject { tm.projects(:id => project_id) }
      it { subject.should be_an_instance_of(Array) }
      it { subject.first.should be_an_instance_of(project_class) }
      it { subject.first.id.should be_eql(project_id) }
    end
  end

  describe "Retrieve a single project" do 
    before(:each) do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/projects.xml', @headers, fixture_for('projects'), 200
        mock.get '/projects/5220065.xml', @headers, fixture_for('projects/5220065'), 200
      end
    end

    context "when calling #project with an id" do 
      subject { tm.project(project_id) }
      it { should be_an_instance_of(project_class) }
      it { subject.id.should be_eql(project_id) }
    end

    context "when calling #project with project attributes" do 
      subject { tm.project(:id => project_id) }
      it { should be_an_instance_of(project_class) } 
      it { subject.id.should be_eql(project_id) }
    end
  end

  describe "Creation and update" do 
    before(:each) do 
      ActiveResource::HttpMock.respond_to do |mock| 
        mock.post '/projects.xml', @wheadesr, '', 200
        mock.get '/projects/5220065.xml', @headers, fixture_for('projects/5220065'), 200
      end
    end

    context "when calling #project!" do 
      subject { tm.project!(:name => 'Project #1') }
      pending { should be_an_instance_of(project_class) }
    end

    context "when changing a project instance and calling #save" do 
      subject { tm.project(project_id) }
      pending { subject.save.should be_false }
    end
  end

end
