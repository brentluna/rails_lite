#route methods
Application.router.draw do

  #get  regex                 Controllernmae  action 
  get Regexp.new("/users$"), UsersController, :index
end
