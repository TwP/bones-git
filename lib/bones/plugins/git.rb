
require 'git'

module Bones::Plugins::Git
  include ::Bones::Helpers
  extend self

  def initialize_git
    have?(:git) {
      Dir.entries(Dir.pwd).include?('.git') and
      quiet { system("git --version") }
    }

    Bones::Plugins::Gem.extend GemOverrides if have? :git
  end

  def define_tasks
    return unless have? :git

    config = ::Bones.config
    namespace :git do

      # A prerequisites task that all other tasks depend upon
      task :prereqs

      desc 'Show tags from the git repository'
      task :tags => 'git:prereqs' do |t|
        puts Git.open('.').tags.map {|tg| tg.name}.reverse
      end

      desc 'Show all log messages since the last release'
      task :changes => 'git:prereqs' do |t|
        tag = Git.open('.').tags.map {|tg| tg.name}.last
        range = tag ? "#{tag}..HEAD" : ''
        system "git log --oneline #{range}"
      end

      desc 'Create a new tag in the git repository'
      task :create_tag => 'git:prereqs' do |t|
        v = ENV['VERSION'] or abort 'Must supply VERSION=x.y.z'
        abort "Versions don't match #{v} vs #{config.version}" if v != config.version

        git = Git.open '.'
        tag = "%s-%s" % [config.name, config.version]
        puts "Creating git tag '#{tag}'."

        begin
          git.add_tag tag
        rescue Git::GitExecuteError
          abort "Tag creation failed: tag '#{tag}' already exists."
        end

        if git.remotes.map {|r| r.name}.include? 'origin'
          unless system "git push origin #{tag}"
            abort "Could not push tag to remote git repository."
          end
        end
      end  # task

      desc 'Delete a tag from the git repository'
      task :delete_tag => 'git:prereqs' do |t|
        v = ENV['VERSION'] or abort 'Must supply VERSION=x.y.z'

        git = Git.open '.'
        tag = "%s-%s" % [config.name, v]

        unless git.tags.map {|tg| tg.name}.include? tag
          puts "Tag '#{tag}' does not exist."
          break
        end

        puts "Deleting git tag '#{tag}'."
        abort 'Tag deletion failed.' unless system "git tag -d '#{tag}'"

        if git.remotes.map {|r| r.name}.include? 'origin'
          unless system "git push origin ':refs/tags/#{tag}'"
            abort "Could not delete tag from remote git repository."
          end
        end
      end  # task

      task :dev_version do |t|
        tag = "%s-%s" % [config.name, config.version]
        rgxp = Regexp.new(Regexp.escape(config.version) + '-(\w+)')
        str = quiet { %x(git describe --tags --match #{tag}) }
        m = rgxp.match(str)
        if m
          config.version = config.version+".#{m[1]}"
          config.gem._spec.version = config.version
        end

      end  # task

    end  # namespace :git

    task 'gem:prereqs' => 'git:dev_version'
    task 'gem:release' => 'git:create_tag'
  end

  # Override the `manifest` method in the Gem plugin so that the list of
  # filese to package is provided from git and its include / exclude rules.
  #
  module GemOverrides

    # This method uses the `git ls-files` command to list the files that
    # should be included in the packaging process for the project.
    #
    # Returns an array of filenames as Strings.
    #
    def manifest
      %x{git ls-files}.split
    end
  end

end  # Bones::Plugins::Git

