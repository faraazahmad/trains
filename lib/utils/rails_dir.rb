module RailsDir
  # checks if supplied dir is in a Rails app dir
  def check(nodes)
    bin_folder = nodes[:children].find { |node| node[:path].include? 'bin' }
    if bin_folder.nil?
      raise ArgumentError, 'Provided folder is not a Rails project'
    end
    rails_exec =
      bin_folder[:children].find { |node| node[:path].include? 'rails' }
    if rails_exec.nil?
      raise ArgumentError, 'Provided folder is not a Rails project'
    end
  end
end
