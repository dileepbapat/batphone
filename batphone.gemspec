Gem::Specification.new do |s|
  s.name = "batphone"
  s.version = '0.2.0'
  s.date = "2008-07-14"
  s.authors = ["Hans Fugal"] 
  s.email = "hans@fugal.net"
  s.summary = "Very simple and easy to learn bridge to AGI (Asterisk Gateway Interface)"
  s.homepage = "http://hans.fugal.net/src/batphone/doc/files/README.html" 
  s.platform = Gem::Platform::RUBY 
  s.description = "Very simple and easy to learn bridge to AGI (Asterisk Gateway Interface)"
   s.files = ["README", "README.fastagi", "ChangeLog", "lib/batphone/agi.rb", "lib/batphone/agi_mixin.rb", 
             "lib/batphone.rb", "lib/batphone/fast_agi_protocol.rb", "lib/batphone/fibered_fast_agi_protocol.rb"]
  s.has_rdoc = true 
  s.extra_rdoc_files = ["README"] 
end 
