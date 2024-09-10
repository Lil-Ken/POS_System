.model small
.stack 100h

.data
	; Predefined data
    username db 'admin', 0
    password db 'pass', 0
    inputBuffer db 20, 0, 20 dup('$')
	optionBuffer db 1 dup(?)
    newlines db 13, 10, '$'
	clearScreens db 25 dup(13, 10), '$'
	multLines12 db 12 dup(13, 10), '$'
	multLines6 db 6 dup(13, 10), '$'
	ten db 10
	hund db 100
	
	; Start messages
    welcomeMsg db 'Welcome to POS System$'
    option1 db '1. Login$'
    option0 db '0. Exit Program$'
    option2 db '1. Try Again$'
    chooseOption db 'Choose an option: $'
	
	; Login messages
    loginPrompt db 'Enter Username: $'
    passPrompt db 'Enter Password: $'
    loginSucc db 'Login successful!$'
    logoutSucc db 'Logout successful!$'
    loginFail db 'Invalid credentials$'
	
	; Main menu options
    menuOption1 db '1. View All Products$'
    menuOption2 db '2. Add Item to Cart$'
    menuOption3 db '3. View Cart$'
    menuOption4 db '4. Remove Item from Cart$'
    menuOption5 db '5. Checkout$'
    menuOption0 db '0. Logout$'
    invalidOption db 'Invalid option, please choose again$'
	
	; Display Items
	item1 db '1. Phone Case               $'
    item2 db '2. Screen Protector         $'
    item3 db '3. Charging Cable           $'
    item4 db '4. Power Bank               $'
    item5 db '5. Wireless Charger         $'
    item6 db '6. Phone Stand              $'
    item7 db '7. Earbuds                  $'
    item8 db '8. Bluetooth Speaker        $'
    item9 db '9. Car Mount                $'
    item10 db '10. Memory Card             $'
	
	; Item Array
	itemArray dw offset item1
              dw offset item2
              dw offset item3
              dw offset item4
              dw offset item5
              dw offset item6
              dw offset item7
              dw offset item8
              dw offset item9
              dw offset item10
	
	; Products
	product1 db 'Phone Case       $'
    product2 db 'Screen Protector $'
    product3 db 'Charging Cable   $'
    product4 db 'Power Bank       $'
    product5 db 'Wireless Charger $'
    product6 db 'Phone Stand      $'
    product7 db 'Earbuds          $'
    product8 db 'Bluetooth Speaker$'
    product9 db 'Car Mount        $'
    product10 db 'Memory Card     $'
	
	; Product Array
	productArray dw offset product1
                 dw offset product2
                 dw offset product3
                 dw offset product4
                 dw offset product5
                 dw offset product6
                 dw offset product7
                 dw offset product8
                 dw offset product9
                 dw offset product10

	prices db 10, 8, 12, 20, 30, 10, 15, 16, 12, 20
	rm db 'RM$'
	
	back db 'Enter 0 to return: $'
	
	
	; View Cart
	viewCartMsg db 'no. | quantity | product name          | price (per unit)     | total prices$', 13, 10
	viewCartLine db '----------------------------------------------------------------------------$', 13, 10
	totalStr    db '                                                      Subtotal: RM$'
	taxStr      db '                                                      Tax (6%): RM $'
	afterTaxStr db '                                                  Total Amount: RM$'
	zero db '.00$'
	priceBuffer db 0
	totalCartPrice db 0
	taxFloatingPoint db 0
	emptyCartMsg db 'Your cart is empty.', 13, 10, '$'
	opt db ?
	numCart db 1
	spaces db '  | $'  ; 4 spaces
	spaces2 db '       | $'  ; 9 spaces
	spaces3 db '     | $'    ; 7 spaces
	spaces4 db '             | $'    ; 15 spaces
	
	
	; Add
	quantityBuffer db 0
    selectedItem db 0			  ; user input index for item
	indexSelectedItem db 0
	cartItems dw 10 dup(0)		  ; indexes of item in cart
	cartQuantities dw 10 dup(0)	  ; quantity of item according to index
	numProduct dw 0
	
	selectItem db 'Select an item (enter 0 to exit): $'
	quantityPrompt db 'Enter quantity (1-10): $'
	invalidSelection db 'Invalid selection, please choose again$'
	invalidQuantityMsg db 'Invalid quantity. Please enter a number between 1 and 10.$'
	addSuccessMsg db 'Product added successfully!$'
	addMorePrompt db 'Do you want to add more products? (Y/N): $'

	
	; remove cart
	cartItemsTemp dw 10 dup(0)		  ; indexes of item in cart
	cartQuantitiesTemp dw 10 dup(0)	  ; quantity of item according to index
	selectRemoveItem db 'Select an item to remove (enter 0 to exit): $'
	error_remove db 'Selected item does not exist!$'
	removePrompt db 'Are you sure to remove the item (Y/N):$'
	successRemove db 'Successfully Remove Item From Cart!$'
	viewCart db ?

	; checkout
	checkoutPrompt db 'Are you sure to make payment (Y/N):$'
	
	; file
	fileName db 'receipt.txt$'
	handle dw ?
	file_success_msg db 'Successfully store in receipt.txt$'
	dot db '.$'
	loopNum db 0
	cartNumStr db '1$'
	
	; Exit messages
    quitPrompt db 'Do you want to quit? (Y/N): $'
    quitMsg db 'Goodbye!$'

.code
main proc
    mov ax, @data
    mov ds, ax
	
	call clearScreen

	; display welcome message
    lea dx, welcomeMsg
    mov ah, 09h
    int 21h

; menu for login or quit
main_menu_start:
	call newline

	; display option 1
    lea dx, option1
    mov ah, 09h
    int 21h

	call newline

	; display option 2
    lea dx, option0
    mov ah, 09h
    int 21h

	call newline

	; ask to choose option
    lea dx, chooseOption
    mov ah, 09h
    int 21h

    ; Get user input for option
    mov ah, 01h
    int 21h
    sub al, 30h
    mov optionBuffer, al

    ; validation
    cmp optionBuffer, 1
    je login_loop          ; Jump to login if 1

    cmp optionBuffer, 0
    je quit_system1         ; Jump to quit if 0

    ; If invalid
	call clearScreen
	
	; display invalid message
    lea dx, invalidOption
    mov ah, 09h
    int 21h
    jmp main_menu_start		; jump back

quit_system1:
	jmp quit_system
	
login_loop:
	call newline
	
    ; Ask for Username: 'admin'
    lea dx, loginPrompt
    mov ah, 09h
    int 21h

    ; input string
    lea dx, inputBuffer
    mov ah, 0Ah
    int 21h
	
	; compare the input lenght
	mov al, inputbuffer[1]
	cmp al, 5 
	jne not_matched
	
	
	lea si, inputbuffer+2	; the input start with index 2
    lea di, username	
    mov cx, 5  
	
	; loop to compare user
	compare_user:
		mov al, [si]
		cmp al, [di]
		jne not_matched
		inc si                      
		inc di
		loop compare_user       

	call newline
	
    ; Ask for Password: 'pass'
    lea dx, passPrompt
    mov ah, 09h
    int 21h
	
	; input string
	mov ah, 0ah             
    lea dx, inputbuffer     
    int 21h
	
	; check the input length 
    mov al, inputbuffer[1]     
    cmp al, 4                  
    jne not_matched
	
	lea si, inputbuffer+2   
    lea di, password        
    mov cx, 4
	
	; loop to compare password
	compare_password:
		mov al, [si]                
		cmp al, [di]                
		jne not_matched              
		inc si                      
		inc di                      
		loop compare_password        
	
	call clearScreen
	
    ; Display login successful message
    lea dx, loginSucc
    mov ah, 09h
    int 21h
    jmp main_menu
	
not_matched:
	call clearScreen
	
    ; Display login failure message
    lea dx, loginFail
    mov ah, 09h
    int 21h
	call newline
    
    ; Ask user to continue or exit program
	; try again
    lea dx, option2
    mov ah, 09h
    int 21h

	call newline

	; exit
    lea dx, option0
    mov ah, 09h
    int 21h
	
	call newline

	; Prompt for option
    lea dx, chooseOption
    mov ah, 09h
    int 21h

    ; Get user input for option
    mov ah, 01h
    int 21h
    sub al, 30h
    mov optionBuffer, al

    ; Check user selection
    cmp optionBuffer, 1
    je login_loop2          ; Jump to login if 1

    cmp optionBuffer, 0
    je quit_system2         ; Jump to quit if 0

    ; invalid option, loop
    jmp not_matched
	
login_loop2:
	jmp login_loop
	
quit_system2:
	jmp quit_system

main_menu:
    ; Display Main Menu
	call newline

    lea dx, menuOption1
    mov ah, 09h
    int 21h

	call newline

    lea dx, menuOption2
    mov ah, 09h
    int 21h

	call newline

    lea dx, menuOption3
    mov ah, 09h
    int 21h

	call newline

    lea dx, menuOption4
    mov ah, 09h
    int 21h

	call newline

    lea dx, menuOption5
    mov ah, 09h
    int 21h

	call newline

    lea dx, menuOption0
    mov ah, 09h
    int 21h

    ; Prompt for option
	call newline

    lea dx, chooseOption
    mov ah, 09h
    int 21h

	; Get user input for option
	mov ah, 01h
	int 21h
	sub al, 30h
	mov optionBuffer, al
	
	call clearScreen

	; Check user selection and call function
	cmp optionBuffer, 1
	je view_items_function1
	;call clearScreen
	;jne skip_view_items_function
	;jmp far ptr view_items_function
	;skip_view_items_function:
	
	cmp optionBuffer, 2
	je add_item_function1
	;jne skip_add_item_function
	;jmp far ptr add_item_function
	;skip_add_item_function:
	
	cmp optionBuffer, 3
	je view_cart_function1
	;jne skip_view_cart_function
	;jmp far ptr view_cart_function
	;skip_view_cart_function:

	cmp optionBuffer, 4
	je remove_item_function1
	;jne skip_remove_item_function
	;jmp far ptr remove_item_function
	;skip_remove_item_function:

	cmp optionBuffer, 5
	je checkout1
	;jne skip_checkout
	;jmp far ptr checkout
	;skip_checkout:

	cmp optionBuffer, 0
	je main1
	;jne invalid_input
	;jmp far ptr main1

	jmp invalid_input
	
view_items_function1:
	jmp view_items_function
	
add_item_function1:
	jmp add_item_function
	
view_cart_function1:
	jmp view_cart_function
	
remove_item_function1:
	jmp remove_item_function
	
checkout1:
	jmp checkout

main1:
    ; Display logout successful message
    lea dx, logoutSucc
    mov ah, 09h
    int 21h
	
	jmp main

invalid_input:

	call clearScreen
    
    ; Display error message
    lea dx, invalidOption
    mov ah, 09h
    int 21h
	
    ; Loop back to the input prompt or menu
    jmp main_menu

view_items_function proc far
	mov bl, optionBuffer
	mov opt, bl
	
	l1:
		; Display the list of items with their prices

		mov cx, 10                
		lea di, itemArray
		lea si, prices  ; Start SI at the beginning of the prices array

		display_loop:
			mov bx, [di]      
			lea dx, [bx]      
			mov ah, 09h       
			int 21h    
			call display_price
			call newline      
			inc si
			add di, 2         
		loop display_loop 
		call newline	
		
		; if jump from menu
		cmp opt, 1
		je main_menu1
		ret
		
	main_menu1:
		jmp main_menu

view_items_function endp

display_price proc
    ; Display the price in RM format
    mov bl, [si]         ; Load the price from the prices array (pointed to by SI)
    call display_amount  ; Display the amount (converts to RM format)
    ret
display_price endp

display_amount proc

    ; Display 'RM'
    lea dx, rm
    mov ah, 09h
    int 21h
	
	mov dl, ' '
    mov ah, 02h
    int 21h

	; 2 digits
	mov ax, 0
	mov al, bl
	DIV ten

	mov bh, ah
	
	mov dl, al
	cmp dl, 0
	je display_space
	add dl, 30h
	mov ah, 02h
	int 21h
	jmp next_digit
	
	display_space:
		mov dl, ' '
		mov ah, 02h
		int 21h

	next_digit:

		mov dl, bh
		add dl, 30h
		mov ah, 02h
		int 21h

		; Display '.'
		mov dl, '.'
		mov ah, 02h
		int 21h

		; Display '0'
		mov dl, '0'
		mov ah, 02h
		int 21h

		; Display '0'
		mov dl, '0'
		mov ah, 02h
		int 21h

		ret
display_amount endp

add_item_function proc
    ; Display the list of items
    call far ptr view_items_function
	
	mov ah, 09h
	lea dx, multLines12
	int 21h

    ; Prompt the user to select an item
    lea dx, selectItem
    mov ah, 09h
    int 21h

    ; Get user input for item selection
	xor ax, ax
    mov ah, 01h
    int 21h
    sub al, '0'  
    mov bl, al  
	
	; second digit 
	xor ax, ax
	mov ah, 01h
    int 21h
	
	cmp al, 0Dh 	; press enter 
	je one_digit
	
    sub al, '0'
	mov bh, al
	
	two_digits:
		mov al, bl
		
		mov bl, ten
		mul bl
		add al, bh
		
		call newline
	
		mov selectedItem, al
		jmp validate

	one_digit:
		mov selectedItem, bl
	
	validate:
		; Validate item selection
		cmp selectedItem, 0
		je return_back
		cmp selectedItem, 1
		jl invalid_item_selection1
		cmp selectedItem, 10
		jg invalid_item_selection1
		
		jmp store_array
		
	return_back:
		call clearScreen
		jmp main_menu
		
	invalid_item_selection1:
		jmp invalid_item_selection
		
	store_array:
		; Decrement selectedItem to make it 0-based
		dec selectedItem
		mov indexSelectedItem, 0

		; Check if the product is already in the cart
		cmp numProduct, 0
		je not_found
		mov cx, [numProduct]    ; CX stores the number of products in the cart
		mov si, offset cartItems
		xor bx, bx              ; Clear BX for the selected item index
		mov bl, selectedItem

	check_existing_product:
		cmp [si], bl            ; Compare selected item index with cartItems
		je found_existing1      ; If found, jump to update quantity
		inc indexSelectedItem	; increase the index
		add si, 2               ; Move to the next item in cartItems
		loop check_existing_product
		jmp not_found
		
	found_existing1:
		jmp found_existing
		
	not_found:
		; If not found in the cart, add it as a new item
		mov si, offset cartItems
		
		xor bx, bx
		mov bx, numProduct
		shl bx, 1
		
		add si, bx    ; Move to the position to add the new product
		mov bl, selectedItem
		mov [si], bl            ; Store the selected item index

		; Add the product quantity
		lea dx, quantityPrompt
		mov ah, 09h
		int 21h

		; Get user input for quantity
		; first character
		mov ah, 01h
		int 21h
		sub al, '0'            ; Convert ASCII to integer
		mov bl, al  
		
		; second character
		mov ah, 01h
		int 21h
		cmp al, 0Dh		; press enter
		je single_digit
		
		; 2 digits
		sub al, '0'
		
		mov bh, ten
		mul bh
		add al, bl
		
		jmp validation
		
		single_digit:
			mov al, bl

		validation:
			mov quantityBuffer, al
			
			; Check if the quantity is valid
			cmp quantityBuffer, 1
			jl invalid_jmp
			cmp quantityBuffer, 10
			jg invalid_jmp
			
			jmp store_quan
		
	invalid_jmp:
		jmp invalid_quantity1
		
	store_quan:
		; Store the quantity in the cartQuantities array
		mov di, offset cartQuantities
		
		xor bx, bx
		mov bx, numProduct
		shl bx, 1
		
		add di, bx    ; Move to the position to store the quantity
		mov [di], al        ; Store the quantity

		; Increment the number of products in the cart
		add numProduct, 1

	success:
		; Display confirmation and ask if the user wants to add more products
		call clearScreen
		
		lea dx, addSuccessMsg
		mov ah, 09h
		int 21h
		
		call newline
		
	add_more_prompt:
		lea dx, addMorePrompt
		mov ah, 09h
		int 21h

		; Get user input (Y/N)
		mov ah, 01h
		int 21h
		cmp al, 'Y'
		je add_item_jmp
		cmp al, 'y'
		je add_item_jmp
		jmp add_return

	add_item_jmp:
		call clearScreen
		jmp add_item_function
		
	add_return:
		; If 'N' or 'n', return to main menu
		cmp al, 'N'
		je main_menu_return1
		cmp al, 'n'
		je main_menu_return1
		; If invalid input, prompt again
		call clearScreen
		jmp add_more_prompt
		
	main_menu_return1:
		jmp main_menu_return

	found_existing:
		; Update the quantity if the item already exists in the cart
		
		lea dx, quantityPrompt
		mov ah, 09h
		int 21h
		
		; first character
		mov ah, 01h
		int 21h
		sub al, '0'            ; Convert ASCII to integer
		mov bl, al  
		
		; second character
		mov ah, 01h
		int 21h
		cmp al, 0Dh		; press enter
		je single_digit2
		
		call newline
		
		; 2 digits
		sub al, '0'
		
		mov bh, ten
		mul bh
		add al, bl
		
		jmp validation2
		
		single_digit2:
			mov al, bl
		
		validation2:
			mov quantityBuffer, al
			
			; Check if the quantity is valid
			cmp quantityBuffer, 1
			jl invalid_jmp1
			cmp quantityBuffer, 10
			jg invalid_jmp1
			
			jmp store_array2

		invalid_jmp1:
			jmp invalid_jmp
			
		store_array2:
		; Update the quantity in the cartQuantities array
		mov di, offset cartQuantities
		
		xor bx, bx
		mov bl, indexSelectedItem
		shl bl, 1
		
		add di, bx         				  ; Move to the correct position in the cartQuantities array
		mov bl, [di]
		add bl, quantityBuffer                        ; Add the new quantity to the existing quantity
		mov [di], bl                      ; Store the updated quantity back into the cart array
		
		jmp main_menu_return              ; Return to main menu

	invalid_more_input:
		call clearScreen
		
		lea dx, invalidOption
		mov ah, 09h
		int 21h
		
		call newline
		
		jmp add_item_function             ; Retry adding item

	invalid_item_selection:
		call clearScreen
		lea dx, invalidSelection
		mov ah, 09h
		int 21h
		
		call newline
		
		jmp add_item_function             ; Retry item selection

	invalid_quantity1:
		call clearScreen
		lea dx, invalidQuantityMsg
		mov ah, 09h
		int 21h
		
		call newline
		
		jmp add_item_function             ; Retry quantity input

	main_menu_return:
		call clearScreen
		jmp main_menu                     ; Return to main menu

add_item_function endp

; no.   quantity   product name   price (per unit)  total prices
view_cart_function proc
    ; Check if the cart is empty
    cmp numProduct, 0
    je cart_empty1
	
	jmp display
	
	cart_empty1:
		jmp cart_empty
		
	display:
		; Display message
		lea dx, viewCartMsg
		mov ah, 09h
		int 21h
		
		call newline
		
		lea dx, viewCartLine
		mov ah, 09h
		int 21h 

		call newline

		xor cx, cx
		mov cx, numProduct
		
		mov si, offset cartItems
		mov di, offset cartQuantities 
		
		mov numCart, 1
		mov totalCartPrice, 0
		
		display_cart_loop:
			
			; display number
			mov dl, numCart
			add dl, 30h
			mov ah, 02h
			int 21h
			
			mov dl, '.'
			mov ah, 02h
			int 21h
			
			lea dx, spaces
			mov ah, 09h
			int 21h
			
			
			
			; display quantity
			xor ax, ax
			mov ax, [di]
			mov quantityBuffer, al
			cmp al, 10
			jl one_digit_quantity
			
			mov ah, 0
			div ten
			mov bx, ax

			mov dl, bl
			add dl, 30h
			mov ah, 02h
			int 21h
			
			mov dl, bh
			add dl, 30h
			mov ah, 02h
			int 21h
			
			jmp display_product_name
			
				one_digit_quantity:
				mov dl, al
				add dl, 30h
				mov ah, 02h
				int 21h
			
				mov dl, ' '
				mov ah, 02h
				int 21h
			
			lea dx, spaces2
			mov ah, 09h
			int 21h
			
			
			
			display_product_name:
			xor ax, ax
			xor bx, bx
			
			mov bx, offset productArray
			mov ax, [si]
			shl ax, 1 			 ; multiply 2 (2 bytes)
			add bx, ax
			
			; display
			mov dx, [bx]
			mov ah, 09h
			int 21h
			
			lea dx, spaces3
			mov ah, 09h
			int 21h
			
			
			
			; display prices
			xor ax, ax
			xor bx, bx
			
			mov bx, offset prices
			
			; get index
			mov ax, [si]
			add bx, ax
			
			mov al, [bx]
			mov priceBuffer, al
			
			; display RM
			lea dx, rm                     
			mov ah, 09h
			int 21h
			
			mov dl, ' '
			mov ah, 02h
			int 21h
			
			; divide 10
			xor ah, ah
			mov al, [bx]
			div ten
			mov bx, ax
			
			cmp bl, 0
			je first_digit
			
			mov dl, bl
			add dl, 30h
			mov ah, 02h
			int 21h
			
			jmp second_digit
			
			first_digit:
			mov dl, ' '
			mov ah, 02h
			int 21h
			
			second_digit:
			mov dl, bh
			add dl, 30h
			mov ah, 02h
			int 21h
			
			; display .00
			mov ah, 09h
			lea dx, zero
			int 21h
			
			lea dx, spaces4
			mov ah, 09h
			int 21h
			
			
			
			; display total price for each item
			mov al, priceBuffer
			mul quantityBuffer
			
			add totalCartPrice, al
			
			; display RM
			lea dx, rm                     
			mov ah, 09h
			int 21h
			
			; divide 100
			xor ah, ah
			div hund
			mov bx, ax
			
			cmp bl, 0
			je first_space
			
			; display x__
			mov dl, bl
			add dl, 30h
			mov ah, 02h
			int 21h
			
			; divide 10
			xor ah, ah
			mov al, bh
			div ten
			mov bx, ax
			jmp skip_compare
			
			first_space: ; display space
			mov dl, ' '
			mov ah, 02h
			int 21h
			
			; divide 10
			xor ah, ah
			mov al, bh
			div ten
			mov bx, ax
			
			cmp bl, 0
			je second_space
			
			skip_compare:
			; display _x_
			mov dl, bl
			add dl, 30h
			mov ah, 02h
			int 21h
			
			jmp skip_space2
			
			second_space: ; display space
			mov dl, ' '
			mov ah, 02h
			int 21h
			
			skip_space2:
			; display __x
			mov dl, bh
			add dl, 30h
			mov ah, 02h
			int 21h
			
			; display .00
			mov ah, 09h
			lea dx, zero
			int 21h
			
			inc numCart
			add si, 2
			add di, 2
			
			call newline
			
			loop display_cart_loop1
			
			jmp skip_loop
			
			display_cart_loop1:
				jmp display_cart_loop
				
			skip_loop:
			call newline
			
			
			
			; display total price
			mov ah, 09h
			lea dx, totalStr
			int 21h
			
			mov al, totalCartPrice
			
			; divide 100
			xor ah, ah
			div hund
			mov bx, ax
			
			cmp bl, 0
			je first_space_total
			
			; display x__
			mov dl, bl
			add dl, 30h
			mov ah, 02h
			int 21h
			
			; divide 10
			xor ah, ah
			mov al, bh
			div ten
			mov bx, ax
			jmp skip_compare2
			
			first_space_total: ; display space
			mov dl, ' '
			mov ah, 02h
			int 21h
			
			; divide 10
			xor ah, ah
			mov al, bh
			div ten
			mov bx, ax
			
			cmp bl, 0
			je second_space_total
			
			skip_compare2:
			; display _x_
			mov dl, bl
			add dl, 30h
			mov ah, 02h
			int 21h
			
			jmp skip_space_total2
			
			second_space_total: ; display space
			mov dl, ' '
			mov ah, 02h
			int 21h
			
			skip_space_total2:
			; display __x
			mov dl, bh
			add dl, 30h
			mov ah, 02h
			int 21h
			
			; display .00
			mov ah, 09h
			lea dx, zero
			int 21h
			
			call newline
			
			
			
			; display tax
			mov ah, 09h
			lea dx, taxStr
			int 21h
			
			mov al, totalCartPrice
			xor ah, ah
			
			; multiply 6
			mov bl, 6
			mul bl
			
			; divide 100
			div hund
			mov cx, ax
			
			; add to total price
			add totalCartPrice, cl
			
			cmp cl, 10
			jge two_digits_tax
			cmp cl, 0
			je zero_digit
			
			mov ah, 02h
			mov dl, ' '
			int 21h
			
			; display first digit
			mov ah, 02h
			mov dl, cl
			add dl, 30h
			int 21h
			
			jmp floating_point
			
			two_digits_tax:
				xor ax, ax
				mov al, cl
				div ten
				mov bx, ax
				
				mov ah, 02h
				mov dl, bl
				add dl, 30h
				int 21h
				
				mov ah, 02h
				mov dl, bh
				add dl, 30h
				int 21h
				
				jmp floating_point
			
			zero_digit:
				mov ah, 02h
				mov dl, ' '
				int 21h
				
				mov ah, 02h
				mov dl, '0'
				int 21h
			
			floating_point:
				mov ah, 02h
				mov dl, '.'
				int 21h
				
				mov taxFloatingPoint, ch
				
				; floating point number
				xor ax, ax
				mov al, ch
				div ten
				mov bx, ax
				
				mov ah, 02h
				mov dl, bl
				add dl, 30h
				int 21h
				
				mov ah, 02h
				mov dl, bh
				add dl, 30h
				int 21h
			
			call newline
			
			
			
			; display after tax price
			mov ah, 09h
			lea dx, afterTaxStr
			int 21h
			
			mov al, totalCartPrice
			
			; divide 100
			xor ah, ah
			div hund
			mov bx, ax
			
			cmp bl, 0
			je first_space_tax
			
			; display x__
			mov dl, bl
			add dl, 30h
			mov ah, 02h
			int 21h
			
			; divide 10
			xor ah, ah
			mov al, bh
			div ten
			mov bx, ax
			jmp skip_compare3
			
			first_space_tax: ; display space
			mov dl, ' '
			mov ah, 02h
			int 21h
			
			; divide 10
			xor ah, ah
			mov al, bh
			div ten
			mov bx, ax
			
			cmp bl, 0
			je second_space_tax
			
			skip_compare3:
			; display _x_
			mov dl, bl
			add dl, 30h
			mov ah, 02h
			int 21h
			
			jmp skip_space_tax2
			
			second_space_tax: ; display space
			mov dl, ' '
			mov ah, 02h
			int 21h
			
			skip_space_tax2:
			; display __x
			mov dl, bh
			add dl, 30h
			mov ah, 02h
			int 21h
			
			;display floating point
			mov dl, '.'
			mov ah, 02h
			int 21h
			
			mov cl, taxFloatingPoint
		
			xor ax, ax
			mov al, cl
			div ten
			mov bx, ax
			
			mov ah, 02h
			mov dl, bl
			add dl, 30h
			int 21h
			
			mov ah, 02h
			mov dl, bh
			add dl, 30h
			int 21h
			
			
			mov ah, 09h
			lea dx, multLines6
			int 21h
			
		cmp viewCart, 'v'
		je back_cart
		
		jmp main_menu
	
		back_cart:
			mov viewCart, 0
			ret
		
	cart_empty:
		; Display message
		lea dx, emptyCartMsg
		mov ah, 09h
		int 21h
		jmp main_menu
view_cart_function endp

remove_item_function proc
    mov viewCart, 'v'
	call view_cart_function
	
	call newline
	call newline
	
	; get number from user
	mov ah, 09h
	lea dx, selectRemoveItem
	int 21h
	
	; input
	mov ah, 01h
	int 21h
	sub al, 30h
	
	mov cx, numProduct
	
	; not exist
	cmp cl, al
	jge exist
	
	call clearScreen
	
	mov ah, 09h
	lea dx, error_remove
	int 21h
	
	jmp main_menu
	
	exist:
	
	; exit
	cmp al, 0
	je cancel_remove
	
	dec al
	mov indexSelectedItem, al
	
	call newline
	
	; confirmation for remove
	mov ah, 09h
	lea dx, removePrompt
	int 21h
	
	xor al, al
	mov ah, 01h
	int 21h
	
	validate_remove:
		cmp al, 'y'
		jmp remove
		cmp al, 'Y'
		jmp remove
		cmp al, 'n'
		jmp cancel_remove
		cmp al, 'N'
		jmp cancel_remove
	
	jmp validate_remove
	
	cancel_remove:
		call clearScreen
		jmp main_menu
		
	remove:
		xor cx, cx
		mov cx, numProduct
		
		mov si, offset cartItems
		mov di, offset cartQuantities
		
		mov bx, offset cartItemsTemp 
		mov bp, offset cartQuantitiesTemp
		
		loop_remove:
			mov al, [si]
			mov ah, [di]
			
			cmp indexSelectedItem, al
			je skip_remove_item

			; store every item in temporary variable
			mov [bx], al
			mov [bp], ah
			
			add bx, 2
			add bp, 2
			jmp inc_add
			
			skip_remove_item:
			dec numProduct
			
			inc_add:
			add si, 2
			add di, 2
			
			loop loop_remove
		
		xor cx, cx
		mov cx, numProduct
		
		mov si, offset cartItems
		mov di, offset cartQuantities
		
		mov bx, offset cartItemsTemp 
		mov bp, offset cartQuantitiesTemp
		
		loop1:
			mov al, [bx]
			mov ah, [bp]
			
			; store every item
			mov [si], al
			mov [di], ah
		
			add bx, 2
			add bp, 2
			add si, 2
			add di, 2
			
			loop loop1
		
		call clearScreen
		
		mov ah, 09h
		lea dx, successRemove
		int 21h
		
		jmp main_menu
remove_item_function endp

checkout proc
    mov viewCart, 'v'
	call view_cart_function
	
	call newline
	call newline
	
	; confirmation
	mov ah, 09h
	lea dx, checkoutPrompt
	int 21h
	
	; input
	xor al, al
	mov ah, 01h
	int 21h
	
	cmp al, 'y'
	je store_file
	cmp al, 'Y'
	je store_file
	
	call clearScreen
	jmp main_menu
	
	store_file:
	; open file
	mov ah, 3Ch
	mov al, 0
	lea dx, fileName
	int 21h
	mov handle, ax 
	
	
	
	; Write to file
	
	mov ah, 40h
	mov bx, handle
	lea dx, viewCartMsg
	mov cx, 76
	int 21h

	; new line
	mov ah, 40h
	mov bx, handle
	lea dx, newlines
	mov cx, 2
	int 21h
	
	mov ah, 40h
	mov bx, handle
	lea dx, viewCartLine
	mov cx, 76
	int 21h
	
	; new line
	mov ah, 40h
	mov bx, handle
	lea dx, newlines
	mov cx, 2
	int 21h
	
	xor cx, cx
	mov cx, numProduct
	mov loopNum, cl
	
	mov si, offset cartItems
	mov di, offset cartQuantities 
	
	file_cart_loop:
		; write number
		mov ah, 40h
		mov bx, handle
		lea dx, cartNumStr
		mov cx, 1
		int 21h
	
		mov ah, 40h
		mov bx, handle
		lea dx, dot
		mov cx, 1
		int 21h
	
		mov ah, 40h
		mov bx, handle
		lea dx, spaces
		mov cx, 4
		int 21h
		
		
		; write quantity
		xor ax, ax
		mov ax, [di]
		mov quantityBuffer, al
		
		mov ah, 40h
		mov bx, handle
		lea dx, quantityBuffer
		mov cx, 1
		int 21h
		
		lea dx, spaces2
		mov ah, 40h
		mov cx, 9
		int 21h
		
			
		display_product_name_file:
		
		; new line
		mov ah, 40h
		mov bx, handle
		lea dx, newlines
		mov cx, 2
		int 21h
	
		dec loopNum
		cmp loopNum, 0
		jne file_cart_loop1
	
		jmp close_file
	
	file_cart_loop1:
		jmp file_cart_loop
		
		
	close_file:
	; Close file
	mov ah, 3Eh 
	mov bx, handle
	int 21h
	
	call clearScreen
	
	file_success:
	mov ah, 09h
	lea dx, file_success_msg
	int 21h
	
	jmp main_menu
    
checkout endp

clearScreen proc
	lea dx, clearScreens
    mov ah, 09h
    int 21h
	ret
clearScreen endp

newline proc
    lea dx, newlines
    mov ah, 09h
    int 21h
    ret
newline endp

quit_system:

	call newline
	
    ; Display Quit Prompt
    lea dx, quitPrompt
    mov ah, 09h
    int 21h

    ; Read User Input (Y/N)
    mov ah, 01h
    int 21h
    cmp al, 'Y'
    je quit_now
    cmp al, 'y'
    je quit_now

    ; If no, go back to main menu
	call clearScreen
    jmp main_menu_start

quit_now:
	call newline
	
    ; Display Goodbye message and exit
    lea dx, quitMsg
    mov ah, 09h
    int 21h
    mov ah, 4Ch
    int 21h


main endp
end main
