/***** 'Or' Train *****/
task or_train;
	input [IN-1:0]	pattern;
	integer i;
	begin
		for ( i = 0; i < IN; i = i + 1 ) begin
			if ( pattern[i] ) begin
				in[i] = CONST1;
			end else begin
				in[i] = CONST0;
			end
		end

		if ( |pattern ) begin
			train = CONST1;
		end else begin
			train = CONST0;
		end

		#(Step);
		t_en = ( out != train );
		#(Step);
		t_en = `Disable;
	end
endtask



/***** 'Or' Test *****/
task or_test (
	input bit [I_PREC-1:0]	Const0,
	input bit [I_PREC-1:0]	Const1
);
	int				pattern;
	bit				or_result;
	bit [IN-1:0]	ans;
	int				i;

	`SetCharGreenBold
	$display("########## or test ##########");
	`ResetCharSetting
	for ( pattern = 0; pattern < (1<<IN); pattern = pattern + 1 ) begin
		for ( i = 0; i < IN; i = i + 1 ) begin
			if ( pattern[i] ) begin
				in[i] = Const1;
			end else begin
				in[i] = Const0;
			end
		end
		or_result = |pattern;
		ans = or_result ? Const1 : Const0;

		#(Step);
		check_input;
		check_out;
		assert ( ans == out ) else begin
			`SetCharRedBold
			$display("Or test failed @ pattern %x, %x, %b", ans, out, pattern);
			`ResetCharSetting
		end
	end

	`SetCharGreenBold
	$display("################################");
	`ResetCharSetting
endtask
