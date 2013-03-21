require 'vclog'
require 'vclog/adapters/git'

describe "git" do
  it "should work" do
    1.should == 1
    repo = VCLog::Repo.new(".")
    #p VCLog::Adapters::Git.new(repo).extract_tags
    require 'awesome_print'
    ap repo.releases(repo.changes)
  end
end