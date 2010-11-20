require 'vclog/adapters/abstract'

module VCLog
module Adapters

  # = Mercurial Adapter
  #
  # TODO: maybe use Amp gem for future version.
  class Hg < Abstract

    # Collect changes.
    #
    def extract_changes
      list = []
      changelog = `hg log -v`.strip
      changes = changelog.split("\n\n\n")
      changes.each do |entry|
        list << parse_entry(entry)
      end
      list
    end

    # Collect tags.
    #
    def extract_tags
      list = []
      if File.exist?('.hgtags')
        File.readlines('.hgtags').each do |line|
          rev, tag = line.strip.split(' ')
          entry = `hg log -v -r #{rev}`.strip
          rev, date, who, msg, type = parse_entry(entry)
          list << [tag, rev, date, who, msg]
        end
      end
      list
    end

    # TODO: check .hgrc
    def user
      ENV['HGUSER'] || ENV['USER']
    end

    #
    def email
      ENV['HGEMAIL'] || ENV['EMAIL']
    end

    #
    def repository
      @repository ||= `hg showconfig paths.default`.strip
    end

    #
    def uuid
      nil
    end

    # TODO: Will multi-line messages work okay this way?
    def tag(ref, label, date, msg)
      mfile = Tempfile.new("message")
      mfile.open{ |f| f << msg }

      date = date.strftime('%Y-%m-%d') unless String===date

      cmd  = %[hg tag -r #{ref} -d #{date} -m "$(cat #{mfile.path})" #{label}]

      puts cmd if $DEBUG
      `#{cmd}` unless $DRYRUN
    end

    private

      def parse_entry(entry)
        rev, date, who, msg = nil, nil, nil, nil
        entry.strip!
        if md = /^changeset:(.*?)$/.match(entry)
          rev = md[1].strip
        end
        if md = /^date:(.*?)$/.match(entry)
          date = md[1].strip
        end
        if md = /^user:(.*?)$/.match(entry)
          who = md[1].strip
        end
        if md = /^description:(.*?)\Z/m.match(entry)
          msg = md[1].strip
        end
        date = Time.parse(date)
        #msg, type = *split_type(msg)
        return rev, date, who, msg
      end

  end

end
end
