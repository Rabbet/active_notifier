guard 'rspec', all_after_pass: false, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/lazy_resource/(.+)\.rb$})     { |m| "spec/lazy_resource/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
