require File.join(File.dirname(__FILE__), '../spec_helper.rb')

describe PostType do
  
  before do
    class Yellow; end
    Object.send(:remove_const, :Yellow)
  end
  
  should "to_s all fields" do
    class Yellow < PostType
      fields :one, :two, :title, :body
      primary :body
      heading :title
    end
    
    yellow = Yellow.new %Q{
      One: hello1
      Two: hello2
      
      This is the title
      =================
      
      this is the body
    }.indents
    
    yellow.to_s.should == %Q{
      one: hello1
      two: hello2
      title: This is the title
      slug: this-is-the-title
      
      this is the body
    }.indents
  end
  
end