module VCLog

  require 'vclog/core_ext'
  require 'vclog/changelog'
  require 'vclog/tag'
  require 'vclog/release'
  require 'erb'

  # A Release History is very similar to a ChangeLog.
  # It differs in that it is divided into releases with
  # version, release date and release note.
  #
  # The release version, date and release note can be
  # descerened from the underlying SCM by identifying
  # the hard tag commits.
  #
  # TODO: Extract output formating from delta parser. Later---Huh?
  #
  class History

    # Location of this file in the file system.
    DIR = File.dirname(__FILE__)

    #
    attr :repo

    ## Alternate title.
    #attr_accessor :title

    ## Current working version.
    #attr_accessor :version

    ## Exclude commit details.
    #attr_accessor :summary

    #
    def initialize(repo)
      @repo = repo

      #opts = OpenStruct.new(opts) if Hash === opts

      #@title   = opts.title || "RELEASE HISTORY"
      #@extra   = opts.extra
      #@version = opts.version
      #@level =  opts.level || 0
    end

    # Tag list from version control system.
    def tags
      @tags ||= repo.tags
    end

    # Changelog object
    #def changelog
    #  @changlog ||= repo.changelog #ChangeLog.new(changes)
    #end

    # Change list from version control system filter for level setting.
    def changes
      @changes ||= (
        if @repo.point
          repo.change_points
        else
          repo.changes
        end
      )
    end

    #
    def releases
      @releases ||= (
        rel = []

        tags = self.tags

        #ver  = repo.bump(version)
        user = repo.user
        time = ::Time.now + (3600 * 24) # one day ahead

        tags << Tag.new(:name=>'HEAD', :id=>'HEAD', :date=>time, :who=>user, :msg=>"Current Development")

        # TODO: Do we need to add a Time.now tag?
        # add current verion to release list (if given)
        #previous_version = tags[0].name
        #if current_version < previous_version  # TODO: need to use natural comparision
        #  raise ArgumentError, "Release version is less than previous version (#{previous_version})."
        #end
        #rels << [current_version, current_release || Time.now]
        #rels = rels.uniq      # only uniq releases

        # sort by release date
        tags = tags.sort{ |a,b| a.date <=> b.date }

        # organize into deltas
        delta = []
        last  = nil
        tags.each do |tag|
          delta << [tag, [last, tag.commit_date]]
          last = tag.commit_date
        end
        # gather changes for each delta
        delta.each do |tag, (started, ended)|
          if started
            set = changes.select{ |c| c.date >= started && c.date < ended  }
            #gt_vers, gt_date = gt.name, gt.date
            #lt_vers, lt_date = lt.name, lt.date
            #gt_date = Time.parse(gt_date) unless Time===gt_date
            #lt_date = Time.parse(lt_date) unless Time===lt_date
            #log = changelog.after(gt).before(lt)
          else
            #lt_vers, lt_date = lt.name, lt.date
            #lt_date = Time.parse(lt_date) unless Time===lt_date
            #log = changelog.before(lt_date)
            set = changes.select{ |c| c.date < ended }
          end

          rel << Release.new(tag, set)
        end
        rel
      )
    end

    # Group +changes+ by tag type.
    def groups(changes)
      @groups ||= changes.group_by{ |e| e.label }  #type
    end

    #
    def to_h
      releases.map{ |rel| rel.to_h }
    end

  end

end
