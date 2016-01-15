
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

  depend_on    'git',   '~> 1.2'

  use_gmail
}

