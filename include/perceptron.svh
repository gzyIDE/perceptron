/*
* <perceptron.svh>
* 
* Copyright (c) 2020 Yosuke Ide
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`ifndef _PERCEPTRON_SVH_INCLUDED_
`define _PERCEPTRON_SVH_INCLUDED_

//***** Calculation Data Type
typedef enum int {
	BOOL,	// boolean
	INT,	// integer
	FXP,	// fixed point
	FP		// floating point
} dtype_t;

//*** Default type
`define DEF_TYPE		INT



//***** Activation Function
typedef enum int {
	STEP,		// f(x) = step(x)
	LINEAR,		// f(x) = x
	ReLU,		// f(x) = x > 0 ? x : 0
	SIGMOID		// f(x) = 1 / (1 + exp(-x))		// not implemented
} actf_t;

//*** Default function
`define DEF_ACT			ReLU



//***** Data Port Configuration 
typedef struct {
	dtype_t		dtype;	// data type
	bit			sign;	// sign(= 1) or unsigned(= 0)
	int 		prec;	// precision
	int 		frac;	// fraction part (for fixed point, floating point)
} dconf_t;

//*** Default Configurations
//* Default Settings
`define DEF_DCONF		dconf_t'{dtype:`DEF_TYPE, sign:1'b0, prec:8, frac:0}
`define DEF_DCONFS		dconf_t'{dtype:`DEF_TYPE, sign:1'b0, prec:4, frac:0}
`define DEF_DCONFL		dconf_t'{dtype:`DEF_TYPE, sign:1'b0, prec:16, frac:0}
//* Boolean
`define DEF_DCONF_B		dconf_t'{dtype:BOOL, sign:1'b0, prec:1, frac:0}
//* Integer
`define DEF_DCONF_INT	dconf_t'{dtype:INT, sign:1'b0, prec:8, frac:0}
`define DEF_DCONFS_INT	dconf_t'{dtype:INT, sign:1'b0, prec:4, frac:0}
`define DEF_DCONFL_INT	dconf_t'{dtype:INT, sign:1'b0, prec:16, frac:0}
//* Fixed Point
`define DEF_DCONF_FXP	dconf_t'{dtype:FXP, sign:1'b0, prec:8, frac:4}
`define DEF_DCONFS_FXP	dconf_t'{dtype:FXP, sign:1'b0, prec:4, frac:2}
`define DEF_DCONFL_FXP	dconf_t'{dtype:FXP, sign:1'b0, prec:16, frac:8}
//* Floating Point
`define DEF_DCONF_FP	dconf_t'{dtype:FP, sign:1'b1, prec:8, frac:3}
`define DEF_DCONFS_FP	dconf_t'{dtype:FP, sign:1'b1, prec:4, frac:2}
`define DEF_DCONFL_FP	dconf_t'{dtype:FP, sign:1'b1, prec:16, frac:5}



//***** expression for convenience
`define Max(A,B)		(A>B)?A:B						// Return larger of the two
`define Min(A,B)		(A<B)?A:B						// Return smaller of the two
`define Max3(A,B,C)		(A>B)?((A>C)?A:C):((B>C)?B:C)	// Return minmum of the three
`define Min3(A,B,C)		(A<B)?((A<C)?A:C):((B<C)?B:C)	// Return maximum of the three



/***** Weight Initialization Option ( default = random ) *****/
`define INIT_ALL_ZERO									// Initialize by zero

`endif //_PERCEPTRON_SVH_INCLUDED_
