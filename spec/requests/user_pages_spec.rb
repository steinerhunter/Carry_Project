require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "index" do
    before do
      sign_in FactoryGirl.create(:user)
      FactoryGirl.create(:user, name: "John", email: "john@gmail.com")
      FactoryGirl.create(:user, name: "Sam", email: "sam@gmail.com")
      visit users_path
    end

    it { should have_selector('title', text: 'All Users') }
    it { should have_selector('h1', text: 'All Users' )}

    it "should list each user" do
      User.all.each do |user|
        page.should have_selector('li', text: user.name)
      end
    end

    describe "delete links" do
      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin)}
        before do
          sign_in admin
          visit users_path
        end

        it {should have_link('delete', href: user_path(User.first))}
        it "should be able to delete other users" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(:admin)) }
      end
    end
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }
    it { should have_selector('title', text: full_title('Sign up')) }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:micropost1) { FactoryGirl.create(:micropost, :user => user, :content => "First post!") }
    let!(:micropost2) { FactoryGirl.create(:micropost, :user => user, :content => "Second post...") }

    before { visit user_path(user)}

    it { should have_selector('h1', text: user.name)}
    it { should have_selector('title', text: user.name)}

    describe "microposts" do
      it { should have_content(micropost1.content) }
      it { should have_content(micropost2.content) }
      it { should have_content(user.microposts.count) }
    end
  end

  describe "signup process" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a new user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

      describe "with valid information" do
        before do
          fill_in "Name", with: "Omer Salomon"
          fill_in "Email", with: "omer.salomon@intel.com"
          fill_in "Password", with: "MyPassword"
          fill_in "Confirmation", with: "MyPassword"
        end

        it "should create a new user" do
          expect { click_button submit }.to change(User, :count).by(1)
        end

        describe "after saving the user" do
          before { click_button submit }
          let(:user) { User.find_by_email('omer.salomon@intel.com') }

          it {should have_link('Sign out') }
        end
      end

  end

  describe "edit user profile" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "edit page" do
      it {should have_selector('h1', text:"Update your profile") }
      it {should have_selector('title', text: "Edit user") }
      it {should have_link('Change picture', href:'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save Changes" }
      it {should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name) { "Someone Else" }
      let(:new_email) { "someone@else.com" }
      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save Changes"
        visit user_path(user)
      end

      it { should have_selector('title', text: new_name) }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end
end