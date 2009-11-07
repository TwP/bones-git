
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'bones-git'

task :default => 'test:run'

Bones {
  name  'bones-git'
  authors  'Tim Pease'
  email  'tim.pease@gmail.com'
  url  'http://github.com/TwP/bones-git'
  version  BonesGit::VERSION
  ignore_file  '.gitignore'
}

# EOF
