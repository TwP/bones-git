
require 'git'

module Bones::App::Git

  def self.initialize_git
    Bones::App::Create.class_eval {
      include ::Bones::App::Git

      option
      option('Git Options:')
      option('--git', 'Initialize a git repository for the project.',
             lambda { |_| config[:git] = true }
      )
      option('--github DESCRIPTION', 'Create a new GitHub project.',
             'Requires a project description.',
             lambda { |desc|
               config[:git] = true,
               config[:github] = true,
               config[:github_desc] = desc
             }
      )

      in_output_directory :initialize_git, :initialize_github
    }
  end

  def initialize_git
    return unless @config[:git]

    File.rename('.bnsignore', '.gitignore') if test ?f, '.bnsignore'

    author = Git.global_config['user.name']
    email  = Git.global_config['user.email']

    if test ?f, 'Rakefile'
      lines = File.readlines 'Rakefile'

      lines.each do |line|
        case line
        when %r/^\s*authors\s+/
          line.replace "  authors  '#{author}'" unless author.nil? or line !~ %r/FIXME/
        when %r/^\s*email\s+/
          line.replace "  email  '#{email}'" unless email.nil? or line !~ %r/FIXME/
        when %r/^\s*url\s+/
          next unless @config[:github]
          url = github_url
          line.replace "  url  '#{url}'" unless url.nil? or line !~ %r/FIXME/
        when %r/^\s*\}\s*$/
          line.insert 0, "  ignore_file  '.gitignore'\n" if test ?f, '.gitignore'
        end
      end

      File.open('Rakefile', 'w') {|fd| fd.puts lines}
    end

    @git = Git.init
    @git.add
    @git.commit "Initial commit to #{name}."
  end

  def initialize_github
    return unless @config[:github]

    user = Git.global_config['github.user']
    token = Git.global_config['github.token']

    raise ::Bones::App::Error, 'A GitHub username was not found in the global configuration.' unless user
    raise ::Bones::App::Error, 'A GitHub token was not found in the global configuration.' unless token

    Net::HTTP.post_form(
        URI.parse('http://github.com/api/v2/yaml/repos/create'),
        'login' => user,
        'token' => token,
        'name' => name,
        'description' => @config[:github_desc]
    )

    @git.add_remote 'origin', "git@github.com:#{user}/#{name}.git"
    @git.config 'branch.master.remote', 'origin'
    @git.config 'branch.master.merge', 'refs/heads/master'
    @git.push 'origin'
  end

  def github_url
    user = Git.global_config['github.user']
    return unless user
    "http://github.com/#{user}/#{name}"
  end

end  # Bones::App::Git

