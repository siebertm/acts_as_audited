require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class AuditsController < ActionController::Base
  def audit
    @company = Company.create
    render :nothing => true
  end
  
  def update_user
    current_user.update_attributes({:password => 'foo'})
    render :nothing => true
  end
  
private
  attr_accessor :current_user
  attr_accessor :additional_audit_attributes
end
AuditsController.view_paths = [File.dirname(__FILE__)]
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }

class AuditsControllerTest < ActionController::TestCase
  should "audit user" do
    user = @controller.send(:current_user=, create_user)
    lambda { post :audit }.should change { Audit.count }
    assigns(:company).audits.last.user.should == user
  end
  
  should "not save blank audits" do
    user = @controller.send(:current_user=, create_user)
    lambda { post :update_user }.should_not change { Audit.count }
  end

  should "use #additional_audit_attributes if set" do
    @controller.send(:additional_audit_attributes=, {:some_attribute => 'some value'})
    lambda { post :audit }.should change { Audit.count }
    assigns(:company).audits.last.some_attribute.should == 'some value'
  end
end
