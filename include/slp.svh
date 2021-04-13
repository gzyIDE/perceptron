/*
* <slp.svh>
* 
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
* 
* This software is released under the MIT License.
* http://opensource.org/licenses/mit-license.php
*/

`ifndef _SLP_SVH_INCLUDED_
`define _SLP_SVH_INCLUDED_

typedef enum {
	RESET_ZERO,		// reset all weight to 0
	RESET_MAX,		// reset all weight to maximum
	RESET_MIN,		// reset all weight to minimum
	RESET_RANDOM	// reset all weight randomly
} SlpReset_t;

`define DEFAULT_SLP_RESET		RESET_ZERO

`endif // _SLP_SVH_INCLUDED_
