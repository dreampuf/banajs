# Helper of BanaJs
# author: dreampuf(soddyque@gmail.com)

crypto = require "crypto"


helper = module.exports = 
  sha1: (data, type="sha1")->
    allowtype = ["sha1", "md5", "sha256", "sha512"]
    throw new Error("type Must in #{allowtype} but then #{type}") if type not in allowtype
    sha1sum = crypto.createHash type
    sha1sum.update data
    sha1sum.digest "hex"



