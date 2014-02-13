# Present

[![Build Status](https://travis-ci.org/coderly/code.png?branch=master)](https://travis-ci.org/coderly/code)
[![Code Climate](https://codeclimate.com/repos/52a0a88e7e00a406ae01ed14/badges/8839d666caf1d188be12/gpa.png)](https://codeclimate.com/repos/52a0a88e7e00a406ae01ed14/feed)

## Overview

Present is a decorator intended to be used in API frameworks, in particular  [Grape](https://github.com/intridea/grape). It is used when exposing model objects in the API layer and allows you to have control over which fields are exposed and in what format they are exposed in.


## Installation

Add this line to your application's Gemfile:

    gem 'present'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install present


## Basic Example

Imagine you have an ActiveRecord model called Business with 3 attributes, id, name, and description.

In your api/my_special_api/entities/business.rb

```ruby
require 'present/entity'

module MySpecialApi
  module Entities
    class Business < Present::Entity
      expose :id, :name, :description
    end
  end
end
```

Then, in your Grape API, you can present it using the with property:
```
get 'businesses' do
  present Business.all, with: Entities::Business
end

get 'businesses/:id' do
  present Business.find(params[:id]), with: Entities::Business
end
```

Ultimately, Grape is calling the Entities::Business.represent method, which is responsible for returning a hash or an array of primitives. This method is able to detect whether you are passing in a collection of objects or a single instance of an object.

## Custom Exposed Attributes
You can expose attributes by creating public methods. Private methods will be ignored but all public methods will be treated as attributes of the entity.

For example

```ruby
class UserEntity < Present::Entity
  
  expose :id, :first_name, :last_name
  
  def full_name
    # Underlying object can be accessed with object method
    object.first_name + ' ' + object.last_name
  end
  
  def age
    time_elapsed_in_years(object.birthday, Time.now)
  end
  
  private
  
  # private method is not exposed as an attribute
  def time_elapsed_in_years(a, b)
    # ...
  end

  def some_random_method
    "howdy"
  end
  
end
```

Then, the following:

```ruby
UserEntity.represent(user)
```

will return something like

```
{
  id: 432,
  first_name: "John",
  last_name: "Smith",
  full_name: "John Smith",
  age: 27
}
```

## Inheritance

Building off the previous example, Present supports inheritance. For example you can do the following:

```ruby
class PremiumUser < User
  expose :points

  def latest_badge
    object.badges.first
  end
end
```

This will emit the following data structure:

```
{
  id: 432,
  first_name: "John",
  last_name: "Smith",
  full_name: "John Smith",
  age: 27,
  points: 983,
  latest_badge: 'top-commentor'
}
```

## Passing in options
You can pass in options when presenting an entity. For example:

```ruby
class EventEntity < Present::Entity
    expose :id, :title

    def time
      time_format = options.fetch(:time_format) { '%Y-%m-%d %H:%i:%s' }
      object.time.strftime(time_format)
    end
  end
end
```

Then, in your Grape API, you can present it and pass any additional options you want along:
```
get 'events/:id' do
  present Event.fetch(params[:id]), with: Event::Entity, time_format: '%m/%d/%y'
end

```

This will output something like the following
```
{
  id: 987,
  title: 'Advanced Basketweaving Class',
  time: '05/16/14'
}
```

- The options are getting passed in the form `EventEntity.represent(object, options)`.
- The options then flow into the constructor like `EventEntity.new(object, options)`

## Gotchas
- Remember to make methods that you do not want to expose private
