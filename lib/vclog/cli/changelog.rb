require 'vclog/cli/abstract'

module VCLog
module CLI

  class Changelog < Abstract

    #
    def self.terms
      ['log', 'changelog']
    end

    #
    def parser
      super do |opt|
        opt.banner = "Usage: vclog [changelog | log] [options]"
        template_options(opt)
      end
    end

    #
    def execute
      format = options.format || 'ansi'
      output = @vcs.display(:changelog, format, options)
      puts output
    end

  end

end
end
