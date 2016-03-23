// Copyright (c) 2015-2016, bacondither
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer
//    in this position and unchanged.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// Adaptive sharpen - version 2015-06-25 - (requires ps >= 3.0)
// Tuned for use post resize

//--------------------------------------- Settings ------------------------------------------------

#define curve_height    1.0                  // Main sharpening strength, POSITIVE VALUES ONLY!
                                             // 0.3 <-> 2.0 is a reasonable range of values

// Defined values under this row are "optimal" DO NOT CHANGE IF YOU DO NOT KNOW WHAT YOU ARE DOING!

#define curveslope      (curve_height*0.7)   // Sharpening curve slope, high edge values
#define D_overshoot     0.001                // Max dark overshoot before max compression
#define D_comp_ratio    0.250                // Max compression ratio, dark overshoot (1/0.25=4x)
#define L_overshoot     0.003                // Max light overshoot before max compression
#define L_comp_ratio    0.167                // Max compression ratio, light overshoot (1/0.167=6x)
#define max_scale_lim   0.1                  // Abs change before max compression (0.1 = +-10%)
//-------------------------------------------------------------------------------------------------

// Saturation loss reduction
#define minim_satloss  ( (c[0].rgb*min((c0_Y + sharpdiff)/c0_Y, 1e+5) + (c[0].rgb + sharpdiff))/2.0 )

// Soft limit
#define soft_lim(v,s)  ( ((exp(2.0*min(abs(v), s*16.0)/s) - 1.0)/(exp(2.0*min(abs(v), s*16.0)/s) + 1.0))*s )

// Get destination pixel values
#define get(x,y)       ( texture(tex, pos + pw*vec2(x, y)).xyz )
#define sat(input)     ( clamp((input).xyz, 0.0, 1.0) )

// Colour to luma
#define CtL(RGB)       ( pow(dot(vec3(0.256, 0.651, 0.093), clamp((RGB).rgb, 0.0, 1.0)), 1.2) )

// Center pixel diff
#define mdiff(a,b,c,d,e,f,g) ( abs(luma[g]-luma[a]) + abs(luma[g]-luma[b])           \
                             + abs(luma[g]-luma[c]) + abs(luma[g]-luma[d])           \
                             + 0.5*(abs(luma[g]-luma[e]) + abs(luma[g]-luma[f])) )

// Compute diff
#define b_diff(z) ( abs(blur-c[z]) )

vec4 sample(sampler2D tex, vec2 pos, vec2 tex_size) {
	// Pixel "width"
	vec2 pw = vec2(1.0 / tex_size.x, 1.0 / tex_size.y);

	vec4 orig = texture(tex, pos);

	// Get points, saturate colour data in c[0]
	// [                c22               ]
	// [           c24, c9,  c23          ]
	// [      c21, c1,  c2,  c3, c18      ]
	// [ c19, c10, c4,  c0,  c5, c11, c16 ]
	// [      c20, c6,  c7,  c8, c17      ]
	// [           c15, c12, c14          ]
	// [                c13               ]
	vec3 c[25] = vec3[](sat( orig), get(-1,-1), get( 0,-1), get( 1,-1), get(-1, 0),
	                    get( 1, 0), get(-1, 1), get( 0, 1), get( 1, 1), get( 0,-2),
	                    get(-2, 0), get( 2, 0), get( 0, 2), get( 0, 3), get( 1, 2),
	                    get(-1, 2), get( 3, 0), get( 2, 1), get( 2,-1), get(-3, 0),
	                    get(-2, 1), get(-2,-1), get( 0,-3), get( 1,-2), get(-1,-2));

	// Blur, gauss 3x3
	vec3  blur   = (vec3(2)*(c[2]+c[4]+c[5]+c[7]) + (c[1]+c[3]+c[6]+c[8]) + vec3(4)*c[0])/vec3(16);
	float blur_Y = dot(blur, vec3(1.0/3.0));

	// Contrast compression, center = 0.5, scaled to 1/3
	float c_comp = clamp(0.266666681f + 0.9*pow(2.0, (-7.4*blur_Y)), 0.0, 1.0);

	// Edge detection
	// Matrix weights
	// [         1/4,        ]
	// [      1,  1,  1      ]
	// [ 1/4, 1,  1,  1, 1/4 ]
	// [      1,  1,  1      ]
	// [         1/4         ]
	float edge = length( b_diff(0) + b_diff(1) + b_diff(2) + b_diff(3)
                       + b_diff(4) + b_diff(5) + b_diff(6) + b_diff(7) + b_diff(8)
                       + 0.25*(b_diff(9) + b_diff(10) + b_diff(11) + b_diff(12)) ) * c_comp;

	// RGB to luma
	float c0_Y = CtL(c[0]);

	float luma[25] = float[](c0_Y, CtL(c[1]), CtL(c[2]), CtL(c[3]), CtL(c[4]), CtL(c[5]), CtL(c[6]),
	                         CtL(c[7]),  CtL(c[8]),  CtL(c[9]),  CtL(c[10]), CtL(c[11]), CtL(c[12]),
	                         CtL(c[13]), CtL(c[14]), CtL(c[15]), CtL(c[16]), CtL(c[17]), CtL(c[18]),
	                         CtL(c[19]), CtL(c[20]), CtL(c[21]), CtL(c[22]), CtL(c[23]), CtL(c[24]));

	// Precalculated default squared kernel weights
	const vec3 w1 = vec3(0.5,           1.0, 1.41421356237); // 0.25, 1.0, 2.0
	const vec3 w2 = vec3(0.86602540378, 1.0, 0.5477225575);  // 0.75, 1.0, 0.3

	// Transition to a concave kernel if the center edge val is above thr
	vec3 dW = pow(mix( w1, w2, smoothstep( 0.3, 0.6, edge)), vec3(2.0));

	float mdiff_c0  = 0.02 + 3.0*( dot(vec4(abs(luma[0]-luma[2]), abs(luma[0]-luma[4]),
	                                      abs(luma[0]-luma[5]), abs(luma[0]-luma[7])), vec4(1.0))
	                           + dot(vec4(abs(luma[0]-luma[1]), abs(luma[0]-luma[3]),
	                                      abs(luma[0]-luma[6]), abs(luma[0]-luma[8])), vec4(0.25)) );

	// Use lower weights for pixels in a more active area relative to center pixel area.
	float weights[12]  = float[](( min((mdiff_c0/mdiff(24, 21, 2,  4,  9,  10, 1)),  dW.y) ),
	                             ( dW.x ),
	                             ( min((mdiff_c0/mdiff(23, 18, 5,  2,  9,  11, 3)),  dW.y) ),
	                             ( dW.x ),
	                             ( dW.x ),
	                             ( min((mdiff_c0/mdiff(4,  20, 15, 7,  10, 12, 6)),  dW.y) ),
	                             ( dW.x ),
	                             ( min((mdiff_c0/mdiff(5,  7,  17, 14, 12, 11, 8)),  dW.y) ),
	                             ( min((mdiff_c0/mdiff(2,  24, 23, 22, 1,  3,  9)),  dW.z) ),
	                             ( min((mdiff_c0/mdiff(20, 19, 21, 4,  1,  6,  10)), dW.z) ),
	                             ( min((mdiff_c0/mdiff(17, 5,  18, 16, 3,  8,  11)), dW.z) ),
	                             ( min((mdiff_c0/mdiff(13, 15, 7,  14, 6,  8,  12)), dW.z) ));

	weights[0] = (max(max((weights[8]  + weights[9])/4.0,  weights[0]), 0.25) + weights[0])/2.0;
	weights[2] = (max(max((weights[8]  + weights[10])/4.0, weights[2]), 0.25) + weights[2])/2.0;
	weights[5] = (max(max((weights[9]  + weights[11])/4.0, weights[5]), 0.25) + weights[5])/2.0;
	weights[7] = (max(max((weights[10] + weights[11])/4.0, weights[7]), 0.25) + weights[7])/2.0;

	// Calculate the negative part of the laplace kernel
	float weightsum   = 0.0;
	float neg_laplace = 0.0;

	for (int pix = 0; pix < 12; ++pix)
	{
		neg_laplace  += luma[pix+1]*weights[pix];
		weightsum    += weights[pix];
	}

	// Compute sharpening magnitude function
	float sharpen_val = (curve_height/(curveslope*pow(abs(edge), 3.5) + 0.5))
	                  - (curve_height/(8192.0*pow((edge*2.4), 4.5) + 0.5));

	// Calculate sharpening diff and scale
	float sharpdiff = (c0_Y - abs(neg_laplace/weightsum))*(sharpen_val*0.8 + 0.01);

	// Calculate local near min & max, partial sort
	for (int i = 0; i < 3; ++i)
	{
		float temp;

		for (int i1 = i; i1 < 24-i; i1 += 2)
		{
			temp = luma[i1];
			luma[i1]   = min(luma[i1], luma[i1+1]);
			luma[i1+1] = max(temp, luma[i1+1]);
		}

		for (int i2 = 24-i; i2 > i; i2 -= 2)
		{
			temp = luma[i];
			luma[i]    = min(luma[i], luma[i2]);
			luma[i2]   = max(temp, luma[i2]);

			temp = luma[24-i];
			luma[24-i] = max(luma[24-i], luma[i2-1]);
			luma[i2-1] = min(temp, luma[i2-1]);
		}
	}

	float nmax = (max(luma[22] + luma[23]*2.0, c0_Y*3.0) + luma[24])/4.0;
	float nmin = (min(luma[2]  + luma[1]*2.0,  c0_Y*3.0) + luma[0])/4.0;

	// Calculate tanh scale factor, pos/neg
	float nmax_scale = min((abs(nmax - c0_Y) + L_overshoot), max_scale_lim);
	float nmin_scale = min((abs(c0_Y - nmin) + D_overshoot), max_scale_lim);

	// Soft limit sharpening with tanh, lerp to control maximum compression
	sharpdiff = mix(  (soft_lim(max(sharpdiff, 0.0), nmax_scale)), max(sharpdiff, 0.0), L_comp_ratio )
	          + mix( -(soft_lim(min(sharpdiff, 0.0), nmin_scale)), min(sharpdiff, 0.0), D_comp_ratio );

	// Normal path
	return vec4(mix((c[0].rgb + sharpdiff), minim_satloss, float(sharpdiff > 0.0)), 1.0);
}
