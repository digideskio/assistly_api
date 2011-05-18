Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = 'assistly'
  s.version      = '0.1.0'
  s.summary      = 'Assistly API Ruby bindings using OAuth.'
  s.description  = 'A simple ruby interface to Assistly.'

  s.author = 'Dennis Theisen'
  s.email = 'soleone@gmail.com'
  s.homepage = 'http://github.com/Soleone/assistly'
  
  s.add_development_dependency('rake')
  s.add_runtime_dependency('oauth', '~> 0.4.4')
  
  s.files = Dir['lib/**/*']
  s.test_files = Dir['test/**/*_test.rb']
  s.require_path = 'lib'
end