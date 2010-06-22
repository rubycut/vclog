require 'vclog/cli/abstract'

module VCLog
module CLI

  class Help < Abstract

    #
    def self.terms
      ['help']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog help"
      end
    end

    #
    def execute
      puts "Usage: vclog [command] [options]"
      puts
      puts "COMMANDS:"
      puts "  changelog      display a Change Log"
      puts "  history        display a Release History"
      puts "  version        display the current tag version"
      puts "  bump           display next reasonable version"
      puts "  list           display format options"
      puts "  help           show help information"
      puts
    end

  end

end
end
