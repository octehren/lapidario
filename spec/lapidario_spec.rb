# frozen_string_literal: true

RSpec.describe Lapidario do
  it "has a version number" do
    expect(Lapidario::VERSION).not_to be nil
  end

  describe "Default gem version explicitation" do
    it "hard-codes versions in Gemfile.lock to the Gemfile, keeping non-gem lines intact" do
      TODO
    end

    it "keeps Gemfile.original for backup purposes" do
      TODO
    end
  end
end
