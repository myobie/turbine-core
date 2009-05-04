# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{turbine-core}
  s.version = "0.5.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Herald"]
  s.date = %q{2009-05-04}
  s.description = %q{TODO}
  s.email = %q{nathan@myobie.com}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "Rakefile",
    "VERSION.yml",
    "lib/turbine-core.rb",
    "lib/turbine-core/ext.rb",
    "lib/turbine-core/importers/hash_importer.rb",
    "lib/turbine-core/importers/json_importer.rb",
    "lib/turbine-core/importers/string_importer.rb",
    "lib/turbine-core/post_type.rb",
    "lib/turbine-core/types/article.rb",
    "lib/turbine-core/types/audio.rb",
    "lib/turbine-core/types/chat.rb",
    "lib/turbine-core/types/link.rb",
    "lib/turbine-core/types/photo.rb",
    "lib/turbine-core/types/quote.rb",
    "lib/turbine-core/types/review.rb",
    "lib/turbine-core/types/video.rb",
    "spec/general/post_type_spec.rb",
    "spec/post_types/article_spec.rb",
    "spec/post_types/chat_spec.rb",
    "spec/post_types/link_spec.rb",
    "spec/post_types/quote_spec.rb",
    "spec/post_types/review_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/myobie/turbine-core}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}
  s.test_files = [
    "spec/general/post_type_spec.rb",
    "spec/post_types/article_spec.rb",
    "spec/post_types/chat_spec.rb",
    "spec/post_types/link_spec.rb",
    "spec/post_types/quote_spec.rb",
    "spec/post_types/review_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
