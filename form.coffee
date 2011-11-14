# Helper of BanaJs
# author: dreampuf(soddyque@gmail.com)

assert = require "assert"
crypto = require "crypto"
url = require "url"

class Form
  constructor:(@title)->
    if !(@ instanceof Form)
      return new Form(@title)
    @fields = {}
    @fieldList = []
    @
  field:(name, title, valid)->
    field = new Field name, title, wrapArray(valid)
    @fields[name] = field
    @fieldList.push field
    @
  validate: (data)->
    f = @
    valid = new Validation @, data
    
    for field in @fieldList
      try
        field.validate valid
      catch exn
        if !(exn instanceof Invalid)
          throw exn
        valid.errorList.push exn
    valid

class Field
  constructor:(@name, @title, @valid)->

  validate: (valid)->
    valid.data[@name] = @validValue(valid.input[@name], valid)

  validValue: (val, valid)->
    f = @
    for validator in @valid
      result = validator.call f, val, valid
      if result != undefined
        val = result
    val

class Validation
  constructor:(@form, @input)->
    @fields = @form.fields
    @data = {}
    @errorList = []

  isValid: ()->
    @errorList.length == 0

  fail: (field, reason)->
    throw new Invalid field, reason

  errors: (fn)->
    (if fn then fn(item) else {name: item.field.name, reason: item.toString()} for item in @errorList)

class Invalid extends Error
  constructor: (@field, @reason)->

  toString: ()->
    "'#{ @field.title }' #{ @reason }."

required = (pattern)->
  pattern = pattern or /\S+/
  (val, valid)->
    if !val
      return valid.fail(@, 'is required')
    else if !pattern.test(val)
      return valid.fail(@, "isn't formatted correctly")

equal = (name)->
  (val, valid)->
    if val != valid.input[name]
      return valid.fail @, "must match '#{ valid.fields[name].title}'"

wrapArray = (val)->
  if val instanceof Array
    return val
  return if val == undefined then [] else [val]

form = module.exports =
  Form : Form
  Field : Field
  required : required
  equal : equal

if require.main == module
  do()-> #test Model
    aform = form.Form("aform")
      .field("email", "Email", form.required(/@/))
      .field("nickname", "Nickname", form.required())
      .field("password", "Password", form.required())

    ret = aform.validate({
      email: "s",
      nickname: "xx" })

    assert.equal ret.isValid(), false
    console.log "errors:", ret.errors()


