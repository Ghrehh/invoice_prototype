module ApplicationHelper
  include CoverimagesHelper
  

  def get_total(inv)
    if inv.total.nil? #checks if the inv has a custom total or not, if not it adds all the prices of the lines
      total = 0
      inv.lines.each do |x|
        quantity = x.quantity || 1
        total += x.price * quantity unless x.price.nil?
      end
      return '%.2f' % total #this nonsense rounds it to 2 decimal places
    else
      return '%.2f' % inv.total
    end
  end
  
def num_digits(num) # gets the length of a fixnum, #need this to get the length of the line cost to readjust the height
  if num > 0
    Math.log10(num).to_i + 1
  else #this lets me get the length of negative numbers
    numstring = num.to_s
    numstring = numstring[1..-1]
    numagain = numstring.to_i
    Math.log10(numagain).to_i + 2
  end
end



  def pdf_method(inv)
    
    @inv = inv
    @block = inv.block
    @user = @inv.user
    @address_arr = [inv.recipient,inv.address_1,inv.address_2,inv.address_3] #creates the ne
    @top_lines = @user.toplines
    @top_offset = @user.topoffset
    @lines = []
    @total = 0
    @date = inv.date
    @due_date = inv.due_date
    @note = inv.note
    @use_picture = @user.use_picture
  
  
  
  
    
    if @block.nil? || @block == "" #makes lines if there's no block yo
    
        
      @inv.lines.each do |x| 
        to_push = [] #holds each line and pushes it to the line array, will only push service and price if they're not nil
  
        to_push << x.service 
        to_push << x.description
        to_push << x.price
        to_push << x.quantity
  
        @lines << to_push
        
        x.quantity = 1 if x.quantity.nil?
        
        @total += (x.price * x.quantity) unless x.price.nil?
      end
      
      
      @total = @inv.total unless @inv.total.nil?
      
    else
      
      @total = @inv.total unless @inv.total.nil? #will asign the total to the custom one unless it's nil
      
    end
    
      
  
    
    
    @top_offset = 0 if @top_offset == nil #santizes top offset
    
    
    catx1 = 180 + 80 + @top_offset # coords for the top right stuff
    catx2 = 370 + 80 + @top_offset
    
    leftwidth = 185
    rightwidth = 160
    
    size = 9
    
    if_first = 720
    x = 0
    
    @top_lines.each_with_index do |line, ind|
      
      if ind == 0 #these thingys need to be here as previously the first bounding box set the location for the rest of them 
        to_use1 = if_first
      else
        to_use1 = cursor - 5
      end
      
      if ind == 0
        to_use2 = if_first
      else
        to_use2 = x - 5
      end
      
    
      bounding_box([catx1, to_use1], :width => leftwidth) do
      	text line.name + ": ", :style => :bold, :align => :right, :size => size
      end
      
      bounding_box([catx2, to_use2], :width => rightwidth) do
      	text line.value, :size => size
      end
      
      x = cursor #setting the cursor so that the bolded part is at the same level as non-bolded. Might consider doing this the way i've handled the main body of the invoices
      
    
    end
    
    
    bounding_box([20, 720], :width => 500) do
    
      #need to make a method thatll check if
      if @user.coverimages.first.nil? || @use_picture == false #if theres no cover image uploaded will use the black placeholder
      
          @user.sender = "Your Company Name" if @user.sender == "" || @user.sender.nil?
      	font("Helvetica", :size => 30, :style => :bold) do
       		text @user.sender
       	end
       	
       	move_down 45
       	
    	else
    	  
        if File.directory?("coverimages/" + @user.name + "/" + @user.coverimages.first.filename) == false #checks if heroku hasn't deleted the image
          write_to_tree(@user.coverimages.first) #remakes the image
        end
        
        image "coverimages/" + @user.name + "/" + @user.coverimages.first.filename, :height => 80
      end
      	
    	
    	move_down 20
    
    	font("Helvetica", :size => 25, :style => :bold) do
     		text "INVOICE"
     	end
    
     	move_down 55
      
     	font("Helvetica", :size => 17, :style => :bold) do
     		text "RECIPIENT"
     	end
    
    	stroke do
    	 # just lower the current y position
    	 horizontal_rule
    	end
    
     	move_down 80
    
     	font("Helvetica", :size => 17, :style => :bold) do
     		text "SERVICES"
     	end
    
    	stroke do
    	 # just lower the current y position
    	 horizontal_rule
    	end
    
     	move_down 370
     	
    
     	font("Helvetica", :size => 17) do
 	     	formatted_text [ 
	                     { text: "TOTAL COSTS ", :styles => [:bold], :size => 17 },
	                     { text: "please make check payable to " +  @user.sender, :size => 10, :styles => [:italic],:color => "3a3a3a" }
	                   ]
     	end
    
    	stroke do
    	 # just lower the current y position
    	 horizontal_rule
    	end
    
    	move_down 35
    
    	stroke do
    	 # just lower the current y position
    	 horizontal_rule
    	end
    
    end
  
    
    
    #if the address fields are nil this turns them into an empty string
    address_arr_fixed = []
    
    @address_arr.each do |x|
      x = "" if x.nil?
      address_arr_fixed << x
    end
    
    address = address_arr_fixed.join("\n")
    
    
   
    unless @date == "" or @date.nil?
      ###########USER INPUTS STUFF################
      bounding_box([25, 580], :width => 500) do
      	
      	formatted_text [ 
      	                     { text: "SENT ON: ", :styles => [:bold], :size => 10 },
      	                     { text: @date, :size => 10 }
      	                   ]
      end
    end
    
    unless @due_date == "" or @due_date.nil?
      ###########USER INPUTS STUFF################
      bounding_box([25, 567], :width => 500) do
    
      	formatted_text [ 
      	                     { text: "DUE BY: ", :styles => [:bold], :size => 10 },
      	                     { text: @due_date, :size => 10 }
      	                   ]
      end
    end
    
    unless @note == "" or @note.nil?
      ###########USER INPUTS STUFF################
      bounding_box([20, 75], :width => 500) do
      	text @note, :style => :italic, :size => 12, :color => "3a3a3a"
      end
    end
    
    bounding_box([25, 506], :width => 500) do
    	text address
    end
    
    startx = 25
    starty = 400
    
    if @block == nil || @block == "" #gets executed if there's no block
      
      
      longest_cost = 0
      longest_quantity = 0
      
      @lines.each do |line| #gets the length of the longest quantity and price to adjust the layout
        unless line[2].nil?
        
          if line[2] == 0 #0 breaks the method that finds the length of the numbers
            length = 1
          else
            length = num_digits(line[2])
          end
          longest_cost = length unless longest_cost > length
        end
        
        unless line[3].nil?
        
          if line[3] == 0 #0 breaks the method that finds the length of the numbers
            length = 1
          else
            length = num_digits(line[3]) 
          end
          longest_quantity = length unless longest_quantity > length
        end
        
      end
      
    
      @lines.each do |x|
        
        unless x[2].nil? #wont run it unless there's a price
        	bounding_box([startx, starty], :width => 495) do
        		text "£" + ( '%.2f' % x[2]) + "", :style => :bold, :align => :right
        	end 
        end
        
        
        text_width = 430 # standard width for the text-field

        
         
        	if longest_cost > 5 # will reduce the size if the cost is too long
        		(longest_cost - 5).times { text_width -= 7}
        	end
        
        
        unless x[3].nil? #wont run it unless there's a price
          bounding_box([startx, starty], :width => text_width) do
          		text "(x" + x[3].to_s + ")", :align => :right
          end 
        end
        
        
        
        text_width = text_width - 40 #defaults amount of space needed  between quantity and description
        
        if longest_quantity > 3 
      		(longest_quantity - 3).times { text_width -= 7}
      	end
        
        
        
      	bounding_box([startx, starty], :width => text_width) do
          if x[0].nil? || x[0] == ""
         		   text x[1]
          else
      		   formatted_text [ 
      	                     { text: x[0], :styles => [:bold] },
      	                     { text: " - " + x[1] }
      	                   ]
          end
      
      	end
      
      	starty = cursor - 7 # changes the start position of the next line
    
      end
      
    else
      
      bounding_box([startx, starty], :width => 500) do
      		text @block
      end
      	
    end
    
    bounding_box([25, 14], :width => 500) do
    	text "£" + ('%.2f' % @total)
    end
    
  end
  
  
end


