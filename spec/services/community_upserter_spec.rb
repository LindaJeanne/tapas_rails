require 'spec_helper' 

describe CommunityUpserter do 
  def params 
    { :nid => "123",
      :depositor => "011",
      :title => "A sample community",
      :access => "public", 
      :members => ["011", "023", "034"]  }
  end

  subject(:community) { Community.find_by_nid(params[:nid]) }

  RSpec.shared_examples "a metadata assigning operation" do 
    its("mods.title")     { should eq [params[:title]] } 
    its(:depositor)       {should eq params[:depositor] } 
    its(:drupal_access)   { should eq params[:access] } 
    its(:project_members) { should match_array params[:members] } 
  end

  context "Create" do 
    before(:all) { CommunityUpserter.upsert params } 
    after(:all) { ActiveFedora::Base.delete_all } 

    it "builds the requested community" do 
      expect(community.class).to eq Community 
    end

    it "assigns the community as a child of the root community" do 
      expect(community.community.pid).to eq Community.root_community.pid
    end

    it_should_behave_like "a metadata assigning operation"
  end

  context "Update" do 
    before(:all) do 
      community = Community.new
      community.nid = "123"
      community.mods.title = "A different title" 
      community.project_members = ["011"]
      community.drupal_access = "private" 

      CommunityUpserter.upsert params
    end

    after(:all) { ActiveFedora::Base.delete_all } 

    it "doesn't build a new community" do 
      expect(Community.all.length).to eq 2 
    end

    it_should_behave_like "a metadata assigning operation" 
  end
end
