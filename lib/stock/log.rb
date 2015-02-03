class Log

  def initialize(file)
    @path = "#{File.dirname(File.expand_path('../../log/', __FILE__))}/#{file}_#{Time.Now.strftime('%Y%m%d%H%M%S')}"
    dir  = File.dirname(@path)
    FileUtils.mkdir_p dir if not File.exists? dir
  end

  def puts(line)
    STDOUT << line + "\n"
    File.open(@path, 'a') do |file|
      file << line + "\n"
    end
  end
end
