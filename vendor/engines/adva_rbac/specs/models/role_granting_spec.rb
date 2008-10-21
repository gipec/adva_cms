# require File.dirname(__FILE__) + '/../spec_local_helper'
# 
# describe Rbac::Role, ".granted_to?", :type => :rbac_role do
#   before :each do
#     Rbac::Role.define :anonymous, 
#                       :grant => true
#                       
#     Rbac::Role.define :user, 
#                       :grant => :registered?, 
#                       :parent => :anonymous
# 
#     Rbac::Role.define :author, 
#                       :require_context => true, 
#                       :grant => lambda{|context, user| context && !!context.subject.try(:is_author?, user) }, 
#                       :parent => :user
# 
#     Rbac::Role.define :moderator, 
#                       :require_context => true, 
#                       :parent => :author 
# 
#     Rbac::Role.define :admin,
#                       :require_context => true, 
#                       :parent => :moderator
# 
#     Rbac::Role.define :owner,
#                       :require_context => true, 
#                       :parent => :admin
# 
#     Rbac::Role.define :superuser, 
#                       :parent => :owner
# 
#     @user.stub! :registered?
#   end
#   
#   it "returns the value given as the :grant option (true)" do
#     Rbac::Role.build(:anonymous).granted_to?(@user).should be_true
#   end
#   
#   it "returns the value given as the :grant option (false)" do
#     Rbac::Role.define :cthulu, :grant => false
#     Rbac::Role.build(:cthulu).granted_to?(@user).should be_false
#   end
#   
#   it "calls the method specified as the :grant option (Symbol)" do
#     @user.should_receive :registered?
#     Rbac::Role.build(:user).granted_to? @user
#   end
#   
#   it "calls proc specified as the :grant option (Proc)" do
#     @content.should_receive(:is_author?).with(@user)
#     Rbac::Role.build(:author, :context => @content).granted_to? @user
#   end
#   
#   it "grants the role :user to a user when he is logged in" do
#     @user.stub!(:registered?).and_return true
#     Rbac::Role.build(:user).granted_to?(@user).should be_true
#   end
#   
#   it "grants the role :admin to a user when the user has the :admin role for the given site" do
#     @user.stub!(:roles).and_return [Rbac::Role.build(:admin, :context => @site)]
#     Rbac::Role.build(:admin, :context => @site).granted_to?(@user).should be_true
#   end
#   
#   it "grants the role :superuser to a user when the user has the :superuser role" do
#     @user.stub!(:roles).and_return [Rbac::Role.build(:superuser)]
#     Rbac::Role.build(:superuser).granted_to?(@user).should be_true
#   end
#   
#   
#   describe "The :superuser role includes all other roles so a superuser has all permissions everywhere all the time." do
#     before :each do
#       @user.roles << Rbac::Role.build(:superuser)
#     end
#     
#     it "grants the user the :superuser role" do
#       @user.should have_role(:superuser)
#     end
#     
#     it "grants the user the :owner role for all accounts" do 
#       [@account, @site, @section, @other_account, @other_site, @other_section, @content, @other_content].each do |context|
#         @user.should have_role(:owner, :context => context)
#       end
#     end
#     
#     it "grants the user the :admin role for all sites" do
#       [@site, @section, @other_site, @other_section, @content, @other_content].each do |context|
#         @user.should have_role(:admin, :context => context)
#       end
#     end
#     
#     it "grants the user the :moderator role for all accounts, sites and sections" do
#       [@account, @site, @section, @other_account, @other_site, @other_section, @content, @other_content].each do |context|
#         @user.should have_role(:moderator, :context => context)
#       end
#     end
#     
#     it "grants the user the :author role for all contents" do
#       [@content, @other_content].each do |context|
#         @user.should have_role(:author, :context => context)
#       end
#     end
#     
#     it "grants the user the :user role" do
#       @user.should have_role(:user)
#     end
#     
#     it "grants the user the :anonymous role" do
#       @user.should have_role(:anonymous)
#     end
#   end
#   
#   describe "the account :owner role includes all roles in the context of the account" do
#     before :each do
#       @user.roles << Rbac::Role.build(:owner, :context => @account)
#     end
#     
#     it "grants the user the :owner role for the account" do
#       [@account, @site, @section, @site_2, @section_2, @content].each do |context|
#         @user.should have_role(:owner, :context => @account)
#       end
#     end
# 
#     it "grants the user the :admin role for all sites and sections included in the account" do
#       [@site, @section, @site_2, @section_2, @content].each do |context|
#         @user.should have_role(:admin, :context => context)
#       end
#     end
# 
#     it "grants the user the :moderator role for the account and all sites and sections that belong to the account" do
#       [@account, @site, @section, @site_2, @section_2, @content].each do |context|
#         @user.should have_role(:moderator, :context => context)
#       end
#     end
# 
#     it "grants the user the :author role for all documents that belong to the account" do
#       @user.should have_role(:author, :context => @content)
#     end
# 
#     it "grants the user the :user role" do
#       @user.should have_role(:user)
#     end
# 
#     it "grants the user the :anonymous role" do
#       @user.should have_role(:anonymous)
#     end
#   end
#   
#   describe "the account :owner role does not include any roles in the context of other accounts" do
#     before :each do
#       @user.roles << Rbac::Role.build(:owner, :context => @account)
#     end
# 
#     it "does not grant the user the :superuser role" do
#       @user.should_not have_role(:superuser)
#     end
# 
#     it "does not grant the user the :owner role for other accounts" do
#       @user.should_not have_role(:owner, :context => @other_account)
#     end
# 
#     it "does not grant the user the :admin role for any sites or sections not included in the account" do
#       [@other_site, @other_section, @other_content].each do |context|
#         @user.should_not have_role(:admin, :context => context)
#       end
#     end
# 
#     it "does not grant the user the :moderator role for other accounts or any sites or sections that do not belong to the account" do
#       [@other_site, @other_section, @other_content].each do |context|
#         @user.should_not have_role(:moderator, :context => context)
#       end
#     end
# 
#     it "does not grant the user the :author role for any documents that do not belong to the account" do
#       @user.should_not have_role(:author, :context => @other_content)
#     end
#   end
#   
#   describe "the :site admin role includes all roles in the context of the site" do
#     before :each do
#       @user.roles << Rbac::Role.build(:admin, :context => @site)
#     end
#   
#     it "grants the user the :admin role for the site" do
#       @user.should have_role(:admin, :context => @site)
#     end 
#   
#     it "grants the user the :moderator role for the site and all sections that belong to the site" do
#       [@site, @section, @content].each do |context|
#         @user.should have_role(:moderator, :context => context)
#       end
#     end 
#   
#     it "grants the user the :author role for all documents that belong to the site" do
#       @user.should have_role(:author, :context => @content)
#     end 
#   
#     it "grants the user the :user role" do
#       @user.should have_role(:user)
#     end 
#   
#     it "grants the user the :anonymous role" do
#       @user.should have_role(:anonymous)
#     end 
#   end
# 
#   describe "the :site admin role does not include any roles in the context of other sites" do
#     before :each do
#       @user.roles << Rbac::Role.build(:admin, :context => @site)
#     end
#     
#     it "does not grant the user the :superuser role" do
#       @user.should_not have_role(:superuser)
#     end 
#   
#     it "does not grant the user the :owner role for any account" do
#       [@account, @other_account].each do |context|
#         @user.should_not have_role(:owner, :context => context)
#       end
#     end 
#   
#     it "does not grant the user the :admin role for any sites not included in the account" do
#       @user.should_not have_role(:admin, :context => @other_site)
#     end 
#   
#     it "does not grant the user the :moderator role for the site's account or any sites or sections that do not belong to the account" do
#       [@account, @other_account, @other_site, @other_section, @other_content].each do |context|
#         @user.should_not have_role(:moderator, :context => context)
#       end
#     end 
#   
#     it "does not grant the user the :author role for any documents that do not belong to the account" do
#       @user.should_not have_role(:author, :context => @other_content)
#     end
#   end
# 
#   describe "When the :moderator is defined in the account context then it includes the :author role for all documents that belong to the account" do
#     before :each do
#       @user.roles << Rbac::Role.build(:moderator, :context => @account)
#     end
#     
#     it "grants the user the :moderator role for the account and all sites and sections that belong to the account" do
#       [@account, @site, @section, @content].each do |context|
#         @user.should have_role(:moderator, :context => context)
#       end
#     end
#     
#     it "grants the user the :author role for all documents that belong to the account" do
#       @user.should have_role(:author, :context => @content)
#     end
#     
#     it "grants the user the :user role" do
#       @user.should have_role(:user)
#     end
#     
#     it "grants the user the :anonymous role" do
#       @user.should have_role(:anonymous)
#     end
#     
#     it "does not grant the user the :superuser role" do
#       @user.should_not have_role(:superuser)
#     end
#     
#     it "does not grant the user the :owner role for any account" do
#       [@account, @other_account].each do |context|
#         @user.should_not have_role(:owner, :context => context)
#       end
#     end
#     
#     it "does not grant the user the :admin role for any site" do
#       [@site, @site_2, @other_site].each do |context|
#         @user.should_not have_role(:admin, :context => context)
#       end
#     end
#   end
# 
#   describe "When the :moderator is defined in the site context then it includes the :author role for all documents that belong to the site" do
#     before :each do
#       @user.roles << Rbac::Role.build(:moderator, :context => @site)
#     end
#     
#     it "grants the user the :moderator role for the site and all sections that belong to the site" do
#       [@site, @section, @content].each do |context|
#         @user.should have_role(:moderator, :context => context)
#       end
#     end
#   
#     it "grants the user the :author role for all documents that belong to the site" do
#       @user.should have_role(:author, :context => @content)
#     end
#   
#     it "grants the user the :user role" do
#       @user.should have_role(:user)
#     end
#   
#     it "grants the user the :anonymous role" do
#       @user.should have_role(:anonymous)
#     end
#   
#     it "does not grant the user the :superuser role" do
#       @user.should_not have_role(:superuser)
#     end
#   
#     it "does not grant the user the :owner role for any account" do
#       [@account, @other_account].each do |context|
#         @user.should_not have_role(:owner, :context => context)
#       end
#     end
#     
#     it "does not grant the user the :admin role for any site" do
#       [@site, @site_2, @other_site].each do |context|
#         @user.should_not have_role(:admin, :context => context)
#       end
#     end
#   
#     it "does not grant the user the :moderator role for any account or \
#         any other sites or sections that belong to the account or \
#         any other sites or sections that do not belong to the account" do
#       [@account, @other_account, @site_2, @section_2, @other_site, @other_section].each do |context|
#         @user.should_not have_role(:moderator, :context => context)
#       end
#     end
#   end
# 
#   describe "When the :moderator is defined in the section context then it includes the :author role for all documents that belong to the section" do
#     before :each do
#       @user.roles << Rbac::Role.build(:moderator, :context => @section)
#     end
#     
#     it "grants the user the :moderator role for the section" do
#       @user.should have_role(:moderator, :context => @section)
#     end
#   
#     it "grants the user the :author role for all documents that belong to the section" do
#       @user.should have_role(:author, :context => @content)
#     end
#   
#     it "grants the user the :user role" do
#       @user.should have_role(:user)
#     end
#   
#     it "grants the user the :anonymous role" do
#       @user.should have_role(:anonymous)
#     end
#   
#     it "does not grant the user the :superuser role" do
#       @user.should_not have_role(:superuser)
#     end
#   
#     it "does not grant the user the :owner role for any account" do
#       [@account, @other_account].each do |context|
#         @user.should_not have_role(:owner, :context => context)
#       end
#     end
#   
#     it "does not grant the user the :admin role for any site" do
#       [@site, @site_2, @other_site].each do |context|
#         @user.should_not have_role(:admin, :context => context)
#       end
#     end
#   
#     it "does not grant the user the :moderator role for any account or any site or any other sections" do
#       [@account, @other_account, @site, @site_2, @section_2, @other_site, @other_section].each do |context|
#         @user.should_not have_role(:moderator, :context => context)
#       end
#     end
#   end
#   
#   describe "the user has authored a content" do
#     before :each do
#       @content.stub!(:is_author?).with(@user).and_return true
#     end
# 
#     it "grants the user the :author role for the document" do
#       @user.should have_role(:author, :context => @content)
#     end
#     
#     # This actually is not true because (as opposed to explicit roles like :admin, :moderator etc.)
#     # the user does not know about all of his contents (could be thousands). So the system can 
#     # not answer the implicit question "are you the author of *any* document?" here ... which 
#     # should be ok though.
#     #
#     # it "grants the user the :user role" do
#     #   @user.should have_role(:user)
#     # end
# 
#     it "grants the user the :anonymous role" do
#       @user.should have_role(:anonymous)
#     end
# 
#     it "does not grant the user the :superuser role" do
#       @user.should_not have_role(:superuser)
#     end 
#         
#     it "does not grant the user the :owner role for any account" do
#       [@account, @other_account].each do |context|
#         @user.should_not have_role(:owner, :context => context)
#       end
#     end 
#         
#     it "does not grant the user the :admin role for any site" do
#       [@site, @site_2, @other_site].each do |context|
#         @user.should_not have_role(:admin, :context => context)
#       end
#     end 
#         
#     it "does not grant the user the :moderator role for any account, site or section" do
#       [@account, @other_account, @site, @site_2, @other_site, @section, @other_section].each do |context|
#         @user.should_not have_role(:moderator, :context => context)
#       end
#     end  
#   end
#   
#   describe "the :user has registered and logged in" do
#     before :each do
#       @user.stub!(:registered?).and_return true
#     end
#   
#     it "grants the user the :user role" do
#       @user.should have_role(:user)
#     end
# 
#     it "grants the user the :anonymous role" do
#       @user.should have_role(:anonymous)
#     end
# 
#     it "does not grant the user the :superuser role" do
#       @user.should_not have_role(:superuser)
#     end
# 
#     it "does not grant the user the :owner role for any account" do
#       [@account, @other_account].each do |context|
#         @user.should_not have_role(:owner, :context => context)
#       end
#     end
# 
#     it "does not grant the user the :admin role for any site" do
#       [@site, @site_2, @other_site].each do |context|
#         @user.should_not have_role(:admin, :context => context)
#       end
#     end
# 
#     it "does not grant the user the :moderator role for any account, site or section" do
#       [@account, @other_account, @site, @site_2, @other_site, @section, @other_section].each do |context|
#         @user.should_not have_role(:moderator, :context => context)
#       end
#     end
# 
#     it "does not grant the user the :author role for any document" do
#       [@content, @other_content].each do |context|
#         @user.should_not have_role(:author, :context => context)
#       end
#     end
#   end
#   
#   describe "the user is not logged in" do
#     before :each do
#       @user.stub!(:registered?).and_return false
#     end
# 
#     it "grants the user the :anonymous role" do
#       @user.should have_role(:anonymous)
#     end
# 
#     it "does not grant the user the :superuser role" do
#       @user.should_not have_role(:superuser)
#     end
# 
#     it "does not grant the user the :owner role for any account" do
#       [@account, @other_account].each do |context|
#         @user.should_not have_role(:owner, :context => context)
#       end
#     end
# 
#     it "does not grant the user the :admin role for any site" do
#       [@site, @site_2, @other_site].each do |context|
#         @user.should_not have_role(:admin, :context => context)
#       end
#     end
# 
#     it "does not grant the user the :moderator role for any account, site or section" do
#       [@account, @other_account, @site, @site_2, @other_site, @section, @other_section].each do |context|
#         @user.should_not have_role(:moderator, :context => context)
#       end
#     end
# 
#     it "does not grant the user the :author role for any document" do
#       [@content, @other_content].each do |context|
#         @user.should_not have_role(:author, :context => context)
#       end
#     end
# 
#     it "does not grant the user the :user role" do
#       @user.should_not have_role(:user)
#     end
#   end
# end