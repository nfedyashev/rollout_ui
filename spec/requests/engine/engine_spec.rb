require 'spec_helper'

describe "Engine" do
  describe "GET /rollout" do
    let(:user) { mock(:user, :id => 5) }

    before do
      $rollout.active?(:featureA, user)
    end

    it "shows requested rollout features" do
      visit "/rollout"

      page.should have_content("featureA")
    end

    describe "percentage" do
      it "allows changing of the percentage" do
        visit "/rollout"

        within("#featureA") do
          select "100", :from => "percentage"
          click_button "Save"
        end

        $rollout.active?(:featureA, user).should be_true
      end

      it "shows the selected percentage" do
        visit "/rollout"

        within("#featureA") do
          select "57", :from => "percentage"
          click_button "Save"
        end

        page.should have_css(".percentage option[selected='selected']", :text => "57")
      end
    end

    describe "groups" do
      before do
        user.stub(:beta_tester? => true)
        $rollout.define_group(:beta_testers) { |user| user.beta_tester? }
      end

      it "allows selecting of groups" do
        visit "/rollout"

        within("#featureA") do
          select "beta_testers", :from => "groups[]"
          click_button "Save"
        end

        $rollout.active?(:featureA, user).should be_true
      end

      it "shows the selected groups" do
        visit "/rollout"

        within("#featureA") do
          select "beta_testers", :from => "groups[]"
          click_button "Save"
        end

        page.should have_css(".groups option[selected='selected']", :text => "beta_testers")
      end
    end

    describe "users" do
      it "allows adding user ids" do
        visit "/rollout"

        within("#featureA") do
          fill_in "users[]", :with => 5
          click_button "Save"
        end

        $rollout.active?(:featureA, user).should be_true
      end

      it "shows the selected percentage" do
        visit "/rollout"

        within("#featureA") do
          fill_in "users[]", :with => 5
          click_button "Save"
        end

        page.should have_css("input.users[value='5']")
      end
    end
  end
end

