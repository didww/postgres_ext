require 'active_record'
require 'minitest/autorun'
require 'database_cleaner'

unless ENV['CI'] || RUBY_PLATFORM =~ /java/
  require 'byebug'
end

require 'dotenv'
Dotenv.load

require 'postgres_ext'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

class Person < ActiveRecord::Base
  has_many :hm_tags, class_name: 'Tag'
  has_many :people_tags
  has_many :tags, through: :people_tags

  def self.wicked_people
    includes(:tags).where(tags: { categories: %w(wicked awesome) })
  end
end

class PeopleTag < ActiveRecord::Base
  belongs_to :person
  belongs_to :tag
end

class Tag < ActiveRecord::Base
  belongs_to :person
end

class ParentTag < Tag
end

class ChildTag < Tag
  belongs_to :parent_tag, foreign_key: :parent_id
end

DatabaseCleaner.strategy = :deletion

class MiniTest::Spec
  class << self
    alias :context :describe
  end

  before { DatabaseCleaner.start }
  after { DatabaseCleaner.clean }
end
