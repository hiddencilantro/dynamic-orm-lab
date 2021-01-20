require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
        column_names = []
        table_info.each do |column|
            column_names << column["name"]
        end
        column_names.compact
    end

    def initialize(attributes_hash = {})
        attributes_hash.each do |key, value|
            self.send("#{key}=", value)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names[1..-1].join(", ")
    end

    # def question_marks_for_insert
    #     (self.class.column_names.size-1).times.map{"?"}.join(", ")
    # end

    # def values_for_insert_two
    #     self.class.column_names[1..-1].map{|column_name| self.send(column_name)}
    # end

    def values_for_insert
        self.class.column_names[1..-1].map{|column_name| "'#{self.send(column_name)}'"}.join(", ")
    end

    def save
        # DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{question_marks_for_insert})", *values_for_insert_two)
        DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
    end

    def self.find_by(attribute)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0]} = ?", attribute.values[0])
    end
end