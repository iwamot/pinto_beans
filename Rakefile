require 'rake'
require 'spec/rake/spectask'

desc 'Run RSpec with RCov'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.spec_opts = ['-c', '-fs']
  t.rcov_opts = ['-x', 'spec']
end
