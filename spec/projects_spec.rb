
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe TaskMapper::Provider::Basecamp::Project do

  let(:headers) { {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'} }
  let(:wheaders) { headers.merge('Content-Type' => 'application/xml') }
  let(:tm) { TaskMapper.new(:basecamp, :token => '000000', :domain => 'ticketmaster.basecamphq.com') }
  let(:project_class) { TaskMapper::Provider::Basecamp::Project }
  let(:project_id) { 5220065 }

  context "When I retrieve projects" do 
    before(:each) do 
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/projects.json', headers, fixture_for('projects', 'json'), 200
        mock.get '/projects/5220065.json', headers, fixture_for('projects/5220065', 'json'), 200
        mock.get '/projects.json', headers, fixture_for('projects','json'), 200
      end
    end
    describe :projects do 
      let(:projects) { tm.projects }
      subject { projects }

      it { should be_an_instance_of(Array) }
      describe :first do 
        subject { projects.first } 
        it { should be_an_instance_of(project_class) }
      end

    end

    describe "#projects with array of id's" do 
      let(:projects) { tm.projects [project_id] }
      subject { projects }

      it { should be_an_instance_of Array }
      describe :first do 
        subject { projects.first }
        it { should be_an_instance_of project_class }
        its(:id) { should be_eql project_id }
      end
    end

    describe "#projects with a hash of project attributes" do 
      let(:projects) { tm.projects :id => project_id }
      subject { projects } 

      it { should be_an_instance_of(Array) }
      describe :first do 
        subject { projects.first }
        it { should be_an_instance_of(project_class) }
        its(:id) { should be_eql(project_id) }
      end
    end

    describe :project do 
      subject { tm.project project_id }
      it { should be_an_instance_of project_class }
      its(:id) { should be_eql project_id }
      its(:name) { should == 'Ticketmaster-basecamp' }
      its(:description) { should == 'Announcement.' }
      its(:created_at) { should be_an_instance_of Time }
      its(:updated_at) { should be_an_instance_of Time }
    end
  end

  describe "Creation and update" do 
    before(:each) do 
      ActiveResource::HttpMock.respond_to do |mock| 
        mock.post '/projects.xml', wheaders, '', 200
        mock.get '/projects/5220065.xml', headers, fixture_for('projects/5220065'), 200
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
