# MotionData

Purpose of this gem is to provide a layer of abstraction on top of CoreData to be used with RubyMotion. It is inspired by ActiveRecord and tries to follow the ruby-way. 

This gem is intended to be used with RubyMotion. It is heavily based (read: copy-paste) of the work done by fousa for
[motion_migrate](https://github.com/fousa/motion_migrate) and [@mattgreen](https://github.com/mattgreen/) for [Nitron](https://github.com/mattgreen/nitron). Whoever I was unhappy with some decisions made in both of these projects, so I decided to spin off my own gem.

Right now the gem is in early development phase and I am not releasing it on ruby gems. 

## Installation

Add this line to your application's Gemfile:

    gem 'motion_data', github: 'svyatogor/motion_data'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motion_data

## Usage

# MotionData

Purpose of this gem is to provide a layer of abstraction on top of CoreData to be used with RubyMotion. It is inspired by ActiveRecord and tries to follow the ruby-way. 

This gem is intended to be used with RubyMotion. It is heavily based (read: copy-paste) of the work done by fousa for
[motion_migrate](https://github.com/fousa/motion_migrate) and [@mattgreen](https://github.com/mattgreen/) for [Nitron](https://github.com/mattgreen/nitron). Whoever I was unhappy with some decisions made in both of these projects, so I decided to spin off my own gem.

Right now the gem is in early development phase and I am not releasing it on ruby gems. 

## Installation

Add this line to your application's Gemfile:

    gem 'motion_data', github: 'svyatogor/motion_data'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motion_data

## Usage

### Defining schema

Rather than use XCode to create CoreData schema it can be generated based on definition made using the DSL provided by this gem. The schema definition is defined separately from your models on purpose as this runs in your native ruby environment rather than rubymotion environment.

The sample db/schema.rb will look like this:

    Schema.define do
      entity :account do
        property :label
        property :email
        property :name
    
        has_many :folders, inverse_of: :account, deletion_rule: :cascade
      end

      entity :folder do
        property :name
        property :type
    
        has_many :messages, inverse_of: :folder, deletion_rule: :cascade
        belongs_to :account, inverse_of: :folders
      end

      entity :message do
        property :uid, type: :integer_32
        property :subject
        belongs_to :folder, inverse_of: :messages
      end
    end

After you are done editing the file run
    rake schema:migrate


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
