#!/usr/bin/env ruby
#billinfo.rb

require './billinfo_methods'
require "./billinfo/version"

module Billinfo
  class Error < StandardError; end

	go = true
	while go
		time = Time.new
		year = time.year
		puts "[1] to make a new entry\n[2] to display entries by category\n[3] to exit"
		puts 
		choice = gets.chomp.to_i
		choice_ary = [1,2,3]
		choice_foo = [choice]
		unless !choice_foo.empty? || (choice_ary & choice_foo)
			print "choose 1 or 2: "
			choice = gets.chomp.to_i
		end

		if choice == 1
			create_categories
			categories = print_standard_categories
			print "enter a category such as: " , categories
			print "\ncategory: "
			category = gets.chomp.to_s

			if category.empty?
				print "you must enter a category\n"
				next
			else
				category = [category]
			end

			while (category & categories).empty?
				puts "your category is not listed."
				print "\nwould you like to add #{category} as a category? [y/n]: "
				choice = gets.chomp.downcase
				if choice == 'y' or choice =='yes'
					create_categories(category)
					categories = print_standard_categories
				else
					next
				end
			end

			puts
			print "enter Month: "
			month = gets.chomp.to_s.capitalize
			month = [month]
			months = ['January','February','March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

			while (month & months).empty?
				puts "You must enter a month."
				print "\nAcceptable months are: " , months
				puts "enter a month: "
				month = [gets.chomp.to_s.capitalize]
			end
			
			print "enter amount: "
			amt = Float(gets.chomp)
			while !amt.is_a?(Float)
				puts "amount must be a number."
				print "\nplease enter a numeric value: "
				amt = gets.chomp
			end
			
			info_hash = {category: category, month: month, amt: amt, year: year}
			
			billdb(info_hash)
			billtotal(info_hash)
			observations(info_hash)
			billavginc(info_hash)
			billavgx(info_hash)
	
		elsif choice == 2
			if !File.file?('billinfo.db')
				puts "You have not made any entries yet - there is nothing to show."
				next
			end

			categories = print_standard_categories

			print categories
			puts "\nenter a category from choices above"
			print "category: "
			category = [gets.chomp.downcase.to_s]
	
			while (category & categories).empty?
				puts "your category is not listed."
				puts "You must choose from the categories above."
				category = [gets.chomp.downcase]
			end
			
			print "enter year to search (form: XXXX): "
			year_foo = [gets.chomp.to_i]
			yrs = uniq_yrs
			
			while year_foo.is_a?(String) || year_foo.empty? || (year_foo & yrs).empty?
				puts "year must be one of the following:"
				print "enter year to search (form: XXXX): "
				year_foo = [gets.chomp.to_i]
			end

			year = [year_foo]
			info_hash = {category: category, year: year}
			printinfo(info_hash)

		elsif choice == 3
			go = false
		else
			next
		end

		if choice <= 2
			print "exit?"
			choice = gets.chomp
			if choice == 'y'
				go = false
			else
				next
			end
		end
	
	end
end
