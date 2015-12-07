Gem::Specification.new do |s|
  s.name          = 'canada-post-ruby'
  s.version       = '0.0.1'
  s.date          = Date.today.to_s
  s.summary       = 'Ruby interface for Canada Post\' API'
  s.authors       = ['Justin Harrison']
  s.email         = 'justin@pyrohail.com'
  s.files         = Dir.glob('lib/**/*')
  s.require_paths = ['lib']
  s.homepage      = 'https://matthin.com'
  s.add_runtime_dependency("httparty", "~> 0.13.0")
  s.add_runtime_dependency("oga", "~> 0.3.0")
end

