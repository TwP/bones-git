
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'

Bones {
  name         'bones-git'
  authors      'Tim Pease'
  email        'tim.pease@gmail.com'
  url          'http://github.com/TwP/bones-git'
  version      '1.0.0'
  ignore_file  '.gitignore'

  depend_on    'bones'
  depend_on    'git'

  use_gmail
  enable_sudo
}

# EOF
