# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe CanteensController do
  describe "#show" do
    let(:canteen) { FactoryGirl.create :canteen_with_meals }

    it "should fetch canteen and canteen's meals for today" do
      get :show, id: canteen.id

      assigns(:canteen).should == canteen
      assigns(:meals).should == canteen.meals.where(date: Time.zone.now.to_date)
    end

    it "should fetch meals for given date parameter" do
      get :show, id: canteen.id, date: Time.zone.now.to_date + 1.day

      assigns(:canteen).should == canteen
      assigns(:meals).should == canteen.meals.where(date: Time.zone.now.to_date + 1.day)
    end
  end

  describe "#update" do
    let(:canteen) { FactoryGirl.create :canteen_with_meals }
    let(:user) { FactoryGirl.create :user }

    it "should not be accessible by anonymous" do
      put :update, id: canteen.id, canteen: { name: 'NewName' }

      canteen.reload
      canteen.name.should_not == 'NewName'

      response.status.should == 401
    end
  end
end