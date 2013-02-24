# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"
require_dependency 'message'

describe "Developers" do
  let(:developer) { FactoryGirl.create :developer }
  let(:canteen) { FactoryGirl.create :canteen, user_id: developer.id }

  before do
    login_as developer
    click_on "Profil"
  end

  context "on my canteens page" do
    before { canteen; click_on "Meine Mensen" }

    it "should be able to add a new canteen feed" do
      click_on "Neue Mensa hinzufügen"

      fill_in "Feed-Url", with: "http://example.org/canteens.xml"
      fill_in "Name", with: "Test-Mensa"
      fill_in "Adresse", with: "Essensweg 34, 12345 Hunger, Deutschland"
      select 'Standard', from: 'Frühste Abrufstunde'
      click_on "Hinzufügen"

      page.should have_content 'Die Mensa wurde erfolgreich hinzugefügt.'
    end

    it "should be able to edit own canteens" do
      click_on "Mensa bearbeiten"

      new_url = "http://example.org/canteens.xml"
      new_name = "Test-Mensa"
      new_address = "Essensweg 34, 12345 Hunger, Deutschlandasd"
      fill_in "Feed-Url", with: new_url
      fill_in "Name", with: new_name
      fill_in "Adresse", with: new_address
      click_on "Speichern"

      canteen.reload

      canteen.url.should == new_url
      canteen.name.should == new_name
      canteen.address.should == new_address


      page.should have_content 'Mensa gespeichert.'
    end

    it "should allow to set fetch_hour for meal" do
      click_on "Mensa bearbeiten"

      select "9 Uhr", from: 'Frühste Abrufstunde'
      click_on "Speichern"

      canteen.reload

      canteen.fetch_hour.should == 9
    end

    it "should allow to set fetch_hour to default" do
      click_on "Mensa bearbeiten"

      select "Standard", from: 'Frühste Abrufstunde'
      click_on "Speichern"

      canteen.reload

      canteen.fetch_hour.should be_nil
    end
  end

  context "on my messages page" do
    let(:message) { FactoryGirl.create :feedValidationError, canteen: canteen, kind: :invalid_xml }
    before { message; click_on "Statusmitteilungen" }

    it "should allow to view own messages" do
      click_on canteen.name
      page.should have_content message.canteen.name
      page.should have_content message.message
    end
  end

  context "on profile page" do
    it "should allow to activate (daily) report mails" do
      developer.send_reports?.should be_false

      check "Sende Error-Reports per Mail (maximal täglich)"
      click_on "Speichern"

      developer.reload

      developer.send_reports?.should be_true
    end

    it "should allow to deactivate (daily) report mails" do
      developer.send_reports = true
      developer.save!

      click_on "Profil"
      uncheck "Sende Error-Reports per Mail (maximal täglich)"
      click_on "Speichern"

      developer.reload

      developer.send_reports?.should be_false
    end
  end
end