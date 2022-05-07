module Logger
  def debug(log)
    puts '[DEBUG]:'.bold.blue
    pp log
  end
end
