require 'spec_helper'

describe TaskMapper::Provider::Basecamp::Project do
  let(:tm) { create_instance }
  let(:project_id) { 5220065 }
  let(:project_class) { TaskMapper::Provider::Basecamp::Project }

  describe "#projects" do
    context "with no arguments" do
      let(:projects) { tm.projects }

      it "returns an array of all projects" do
        expect(projects).to be_an Array
        expect(projects.first).to be_a project_class
      end
    end

    context "with an array of project IDs" do
      let(:projects) { tm.projects [project_id] }

      it "returns an array of matching projects" do
        expect(projects).to be_an Array
        expect(projects.first).to be_a project_class
        expect(projects.first.id).to eq project_id
      end
    end

    context "with a hash of project attributes" do
      let(:projects) { tm.projects :id => project_id }

      it "returns an array containing the matching project" do
        expect(projects).to be_an Array
        expect(projects.first).to be_a project_class
        expect(projects.first.id).to eq project_id
      end
    end
  end

  describe "#project!" do
    context "with a project name" do
      let(:project) { tm.project! :name => "Project #1" }

      it "creates a new project" do
        expect(project).to be_a project_class
        expect(project.name).to eq "Project #1"
      end
    end
  end
end
