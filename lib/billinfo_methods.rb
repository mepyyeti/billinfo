#!/usr/bin/env ruby
#billinfo_methods.rb

require 'sqlite3'

def create_categories(new_category = nil)
	unless File.file?('billinfo.db')
		categories = ['electricity','water','cable','streaming','rent','food','clothes','out \'n about']
		begin
			db = SQLite3::Database.open('billinfo.db')
			db.transaction
			db.execute2 "CREATE table if not exists categories(Type TEXT PRIMARY KEY)"
			categories.each { |cat| db.execute2 "INSERT into categories(Type) values(:Type)", cat }
			db.commit
		rescue SQLite3::Exception => e
			puts e
			db.rollback
		ensure
			db.close if db
		end
	end
	if new_category != nil
		begin 
			db = SQLite3::Database.open('billinfo.db')
			db.transaction
			db.execute2 "INSERT into categories(Type) values(:new_category)", new_category
			db.commit
			puts db.changes.to_s + " new category added"
		rescue SQLite3::Exception => e
			puts e
			db.rollback
		ensure
			db.close if db
		end
	end
end

def print_standard_categories
	begin
		db = SQLite3::Database.open('billinfo.db')
		db.results_as_hash = true
		categories_to_print = []
		categories = db.prepare "SELECT Type FROM categories"
		categories.execute
		categories.each { |cat| categories_to_print << cat[0] }
		@categories_to_print = categories_to_print
	rescue SQLite3::Exception => e
		puts e
	ensure
		categories.close if categories
		db.close if db
	end
	@categories_to_print
end

def billdb(info_hash)
	begin
		db = SQLite3::Database.open('billinfo.db')
		db.transaction
		db.execute2 "CREATE table if not exists bills(Id INTEGER PRIMARY KEY, Type TEXT, Month TEXT, Year INTEGER, Amount FLOAT, AvgInc FLOAT, AvgX FLOAT, Total FLOAT)"
		db.execute2 "INSERT into bills(Type, Month, Year, Amount) values(:Type, :Month, :Year, :Amount)", info_hash[:category], info_hash[:month], info_hash[:year], info_hash[:amt]
		db.commit
		puts db.changes.to_s + " entry made"
	rescue SQLite3::Exception => e
		puts e
		db.rollback
	ensure
		db.close if db
	end
end

def billtotal(info_hash)
	begin
		db = SQLite3::Database.open('billinfo.db')
		db.transaction
		get_amt =  db.execute2 "SELECT sum(Amount) from bills WHERE Type = :Type AND Year = :Year", info_hash[:category], info_hash[:year]
		db.execute2 "UPDATE bills SET Total = :Total WHERE Type = :Type AND Year = :Year", get_amt[1][0], info_hash[:category], info_hash[:year]
		@total_amt=get_amt[1][0]
				if db.changes == 1
			alter = "change"
		else
			alter = "changes"
		end
		puts db.changes.to_s + " #{alter} made to " + info_hash[:category].to_s + " for " + info_hash[:year].to_s
		db.commit
	rescue SQLite3::Exception => e
		puts "error here " , e
	ensure
		db.close if db
	end
	@total_amt
end

def observations(info_hash)
	begin
		db = SQLite3::Database.open('billinfo.db')
		total_rows =  db.execute2 "SELECT COUNT(*) from bills WHERE Type = :Type AND Year = :Year", info_hash[:category], info_hash[:year]
	rescue SQLite3::Exception => e
		puts "error here " , e
	ensure
		db.close if db
	end
	@total_rows=total_rows[1][0]
end

def billavginc(info_hash)
	begin
		db = SQLite3::Database.open('billinfo.db')
		db.transaction
		@avginc = @total_amt / @total_rows
		update_avginc =  db.execute2 "SELECT Amount from bills WHERE Type = :Type AND Year = :Year", info_hash[:category], info_hash[:year]
		update_avginc.each do |line|
			db.execute2 "UPDATE bills SET AvgInc = :AvgInc WHERE Type = :Type AND Year = :Year", @avginc, info_hash[:category], info_hash[:year]
			end
		if db.changes == 1
			alter = "change"
		else
			alter = "changes"
		end
		puts db.changes.to_s + " #{alter} made " + "for #{info_hash[:year].to_s}"
		db.commit
	rescue SQLite3::Exception => e
		puts "error here " , e
	ensure
		db.close if db
	end
end

def billavgx(info_hash)
	begin
		db = SQLite3::Database.open('billinfo.db')
		db.results_as_hash = true
		db.transaction
		specific_amt =  db.prepare "SELECT Amount FROM bills WHERE Type = :Type AND Year = :Year" 
		specific_amt.execute info_hash[:category], info_hash[:year]
		specific_amt.each do |specific_row|
			if @total_rows == 1
				avgx = @total_amt / @total_rows
			elsif @total_rows > 1
				avgx = (@total_amt - specific_row[0]) / (@total_rows - 1)
			else
				puts "insufficient entries"
				return "insufficient entries"
			end	
			db.execute2 "UPDATE bills SET AvgX = :AvgX WHERE Amount = :Amount AND Type = :Type AND Year = :Year", avgx, specific_row[0], info_hash[:category], info_hash[:year]
		end
		db.commit
	rescue SQLite3::Exception => e
		puts "error here " , e
	ensure
		specific_amt.close if specific_amt
		db.close if db
	end
end

def uniq_yrs
	begin
		db = SQLite3::Database.open('billinfo.db')
		yrs = []
		db_print = db.execute2 "SELECT Year FROM bills"
		db_print.each do |yr|
			yrs << yr[0]
		end
		yrs.shift
		@yrs = yrs.uniq
	rescue SQLite3::Exception => e
		puts e
	ensure
		db.close if db
	end
	p @yrs.class
	@yrs
end

def printinfo(info_hash)
	begin
		db = SQLite3::Database.open('billinfo.db')
		db_print = db.execute2 "SELECT * FROM bills WHERE Type = :Type AND Year = :Year", info_hash[:category], info_hash[:year]
		db_print.each do |line|
			puts "%s %s %s %s %s [%s | %s] %s" % [line[0], line[1], line[2], line[3], line[4], line[5], line[6], line[7], line[8]]
		end
	rescue SQLite3::Exception => e
		puts e
	ensure
		db.close if db
	end
end
