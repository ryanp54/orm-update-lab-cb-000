require_relative "../config/environment.rb"

class Student

	attr_accessor :name, :grade
	attr_reader :id

	def initialize(name, grade, id=nil)
		@name = name
		@grade = grade
		@id = id
	end

	def save
		if self.id
			self.update
		else
			sql = <<-SQL
			INSERT INTO students (name, grade)
			VALUES (?, ?)
			SQL
			DB[:conn].execute(sql, [name, grade])
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
			self
		end
	end

	def update
		sql = <<-SQL
		UPDATE students
		SET name = ?, grade = ?
		WHERE id = ?
		SQL
		DB[:conn].execute(sql, name, grade, id)
		self
	end

	def self.create_table
		sql = <<-SQL
		CREATE TABLE IF NOT EXISTS students (
			id INTEGER PRIMARY KEY,
			name TEXT,
			grade INTEGER)
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		DB[:conn].execute("DROP TABLE IF EXISTS students")
	end

	def self.create(name, grade)
		student = Student.new(name, grade)
		student.save
	end

	def self.new_from_db(params)
		Student.new(params[1], params[2], params[0])
	end

	def self.find_by_name(name)
		sql = <<-SQL
		SELECT * FROM students
		WHERE name = ? LIMIT 1
		SQL
		params = DB[:conn].execute(sql, [name]).first
		new_from_db(params)
	end

end
