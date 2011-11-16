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

rule = 
  required : (pattern)->
    pattern = pattern or /\S+/
    (val, valid)->
      if !val
        return valid.fail(@, 'is required')
      else if !pattern.test(val)
        return valid.fail(@, "isn't formatted correctly")
  
  equal : (name)->
    (val, valid)->
      if val != valid.input[name]
        return valid.fail @, "must match '#{ valid.fields[name].title}'"
  
  email :()->
    pattern = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i
    (val, valid)->
      if !pattern.test(val)
        return valid.fail(@, "isn't email address")


wrapArray = (val)->
  if val instanceof Array
    return val
  return if val == undefined then [] else [val]

form = module.exports =
  Form : Form
  Field : Field
  rule : rule

if require.main == module
  do()-> #test Model
    aform = form.Form("aform")
      .field("email", "Email", form.rule.email())
      .field("nickname", "Nickname", form.rule.required())
      .field("password", "Password", form.rule.required())

    ret = aform.validate({
      email: "s",
      nickname: "xx" })

    assert.equal ret.isValid(), false
    assert.deepEqual ret.errors(), [{ name: 'email', reason: '\'Email\' isn\'t email address.' }, { name: 'password', reason: '\'Password\' is required.' }]

    ret = aform.validate({
      email: "soddyque@gmail.com"
      nickname: "dreampuf"
      password: "xxx"})

    assert.ok ret.isValid()
    console.log ret.data


