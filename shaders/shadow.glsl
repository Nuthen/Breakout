vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 texcolor = Texel(texture, texture_coords);
	number fade = pow((screen_coords.y-80)/1000, (.35));
	
	//if (screen_coords.y >= 300) {
		texcolor.r *= fade;
		texcolor.g *= fade;
		texcolor.b *= fade;
	//};
	
    return texcolor * color;
}