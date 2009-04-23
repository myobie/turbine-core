require File.join(File.dirname(__FILE__), '../spec_helper.rb')

describe Chat do
  
  before do
    class Yellow; end
    Object.send(:remove_const, :Yellow)
  end
  
  should "pull the title out of an article" do
    Article.new("Hello\n=====\n\nWorld").get_attr(:title).should == "Hello"
  end
  
  should "allow quotes in articles" do
    Article.new("Hello\n=====\n\nThis has a quote in it.\n\n> This is the quote\n> \n> And the rest of the quote\n\nAnd the rest of the article").get_attr(:body, false).should == "This has a quote in it.\n\n> This is the quote\n> \n> And the rest of the quote\n\nAnd the rest of the article"
  end
  
  should "know that an article with a quote in it is not a Quote" do
    PostType.auto_detect("Hello\n=====\n\nThis has a quote in it.\n\n> This is the quote\n> \n> And the rest of the quote\n\nAnd the rest of the article").should.be.kind_of Article
  end
  
end