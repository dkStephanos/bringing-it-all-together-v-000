require_relative "../config/environment.rb"
require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(name, breed, id = nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.new_from_db(row)
    Dog.new(row[1], row[2], row[0])
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM dogs
    SQL

    DB[:conn].execute(sql).collect do |row|
      Dog.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).collect do |row|
      #binding.pry
      Dog.new_from_db(row)
    end.first
  end

  def self.create(name, breed)
    dog = Dog.new(name, breed)
    dog.save
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
end
