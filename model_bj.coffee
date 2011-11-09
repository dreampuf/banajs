# New Model of BanaJs
# author: dreampuf(soddyque@gmail.com)


class Model
  constructor: ()->
  

class User extends Model
  _ds : []
  constructor: (d)->
    @email = d.email
    @password = d.password

