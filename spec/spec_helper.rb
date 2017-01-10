RSpec.configure do |config|
	original_stderr = $stderr
	original_stdout = $stdout
	config.before(:all) do
		$stderr = File.new(File.join(__dir__, 'dev', 'null.txt'), 'w')
		$stdout = File.new(File.join(__dir__, 'dev', 'null.txt'), 'w')
	end
	config.after(:all) do
		$stderr = original_stderr
		$stdout = original_stdout
	end
end