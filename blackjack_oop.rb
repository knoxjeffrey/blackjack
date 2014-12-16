Dir[File.join(File.dirname(__FILE__), 'app', '*.rb')].each do |file_path|
  require file_path
end
GameFlow.new.game