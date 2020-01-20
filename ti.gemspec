Gem::Specification.new do |s|
    s.name = 'ti'
    s.version = '0.0.1'
    s.date = '2020-01-17'
    s.summary = 'Micro-SDK for TI'
    s.description = 'Facilitates use of https://api.thoughtindustries.com'
    s.authors = ['Ben Dunlap']
    s.email = 'ben@adjusterpro.com'
    s.files = ['lib/ti.rb']
    s.homepage = 'https://github.com/AdjusterPro/ti'
    s.license = 'MIT'

    s.add_runtime_dependency 'open-uri'
    s.add_runtime_dependency 'net/http'
    s.add_runtime_dependency 'json'
end
