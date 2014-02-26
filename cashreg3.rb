require 'csv'

def get_from_csv(hash)
  index = 1
  CSV.foreach('products.csv', headers: true) do |row|
    hash[index] = {row.headers[0] => row[0], row.headers[1] => row[1], row.headers[2] => row[2].to_f, row.headers[3] => row[3].to_f}
  index += 1
  end
  hash
end

def subtotal(amount)
  puts
  puts "Subtotal: #{format_currency(amount)}"
  puts
end

def print_options(hash)
  puts "Welcome to Joe's coffee emporium!"
  puts
  hash.each do |index, values|
    puts "#{index}) Add item - #{format_currency(values["retail_price"])} - #{values["name"]}"
  end
  puts "4) Complete Sale"
  puts "5) Reporting"
  puts
end

def month_converter(num)
  if num == "01"
    "January"
  elsif num == "02"
    "February"
  elsif num == "03"
    "March"
  elsif num == "04"
    "April"
  elsif num == "05"
    "May"
  elsif num == "06"
    "June"
  elsif num == "07"
    "July"
  elsif num == "08"
    "August"
  elsif num == "09"
    "September"
  elsif num == "10"
    "October"
  elsif num == "11"
    "November"
  elsif num == "12"
    "December"
  end
end

def sale_complete(hash_data, hash_quantity)
  puts "===Sale Complete==="
  puts
  hash_quantity.each do |index, values|
    puts "#{format_currency(hash_quantity[index]["quantity"] * hash_data[index]["retail_price"])} - #{hash_quantity[index]["quantity"]} #{hash_data[index]["name"]}"
    File.open('report.csv', 'a') do |f|
      f.puts Time.now.strftime("%m/%d/%Y") + ",#{hash_data[index]["SKU"]},#{hash_data[index]["name"]},#{hash_quantity[index]["quantity"]},#{(hash_quantity[index]["quantity"] * hash_data[index]["retail_price"].to_f)},#{((hash_quantity[index]["quantity"] * hash_data[index]["retail_price"].to_f) - (hash_quantity[index]["quantity"] * hash_data[index]["wholesale_price"].to_f))}"
    end
  end
end

def format_currency(value)
  "$#{sprintf('%.2f', value.to_f)}"
end

def receipt(cash, sub_total)
  change = cash - sub_total
  if cash < sub_total
    change = change.abs
    puts "WARNING: Customer still owes: " + format_currency(change)  + " Exiting..."
  else
    puts
    puts '============THANK YOU============'
    puts "The total change due is: " + format_currency(change)
    puts
    puts Time.now.strftime('%m/%d/%Y %l:%M%p')
    puts '================================='
  end
end

#++++++++++++++++++++++++++++PROGRAM++++++++++++++++++++++++++

coffee_info = {}
total = 0
selection = 1
complete_sale = {}

get_from_csv(coffee_info)

print_options(coffee_info)

while (1..3) === selection
  puts "Make a selection:"
  selection = gets.chomp.to_i
  puts
  if (1..3) === selection
    puts "How many?"
    how_many = gets.chomp.to_i
      while how_many < 1
        puts "Please enter a valid number: "
        how_many = gets.chomp.to_i
      end
    total += coffee_info[selection]["retail_price"].to_f * how_many
    if complete_sale[selection] == nil
      complete_sale[selection] = { "quantity" => how_many }
    else
      complete_sale[selection] = { "quantity" => how_many + complete_sale[selection]["quantity"] }
    end
    subtotal(total)

  elsif selection != 4  && selection != 5
    puts "Please make a valid selection"
    selection = 1
  end
end

if selection == 4

  if File.exist?("report.csv") == false
    File.open('report.csv', 'w') do |f|
      f.puts "date,SKU,name,quantity,revenue,profit"
    end
  end

  sale_complete(coffee_info, complete_sale)

  puts
  puts "Total: #{format_currency(total)}"
  puts
  puts "What is the amount tendered?"
  cash_paid = gets.chomp.to_f
  puts

  receipt(cash_paid, total)
else
  puts "What date would you like reports for? (MM/DD/YYYY)"
  date = gets.chomp
  while date.split("/")[0].to_i > 12 || date.split("/")[0].to_i < 1 || date.split("/")[1].to_i  > 31 || date.split("/")[1].to_i  < 1 || date.split("/")[2].to_i  < 2000 || date.split("/")[2].to_i  > Time.now.strftime("%Y").to_i
    puts "Please enter a valid date (MM/DD/YYYY):"
    date = gets.chomp
  end
  print "On #{month_converter(date.split("/")[0])} #{date.split("/")[1]}, #{date.split("/")[2]} we sold:"
  puts
  puts
  datein = ''
  sales = 0.00
  profits = 0.00
  CSV.foreach('report.csv', headers: true) do |row|
    datein = row[0]
    if date == datein
      puts "SKU #: #{row[1]}, Name: #{row[2]}, Quantity: #{row[3]}, Revenue: #{format_currency(row[4])}, Profit: #{format_currency(row[5])}"
      profits += row[5].to_f
      sales += row[4].to_f
    end
  end
  if profits == 0
    puts "No Sales"
  else
    puts
    puts "Total Sales: #{format_currency(sales)}"
    puts "Total Profit: #{format_currency(profits)}"
  end
end












