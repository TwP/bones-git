
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

  depend_on    'bones', '>= 3.6'
  depend_on    'git'

  use_gmail
}

