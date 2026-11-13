// Zeitblase als Linse (Doku 2.3, Schritt 19b): verzerrt das Bild innerhalb
// der Blase leicht (Wobble wie durch Wasser oder gekruemmtes Glas) und
// verschiebt die Farbkanaele (chromatische Aberration). Die dabei
// entstehenden Mischfarben sind erlaubt (Ausnahme Zeitblase, Doku 1.7).
// Die Phase setzt das Skript (Tempo je Zeitstufe), alle Staerken in Pixeln.
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
// Auslenkung des Wobble in Pixeln.
uniform float wobble_strength = 1.5;
// Wellen pro Pixel (groesser = kleinere Wellen).
uniform float wobble_scale = 0.08;
// Verschiebung der Farbkanaele in Pixeln (rot nach rechts, blau nach links).
uniform float aberration = 1.0;
// Fortschritt der Welle (vom Skript hochgezaehlt).
uniform float phase = 0.0;

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE;
	vec2 wobble = vec2(
		sin(FRAGCOORD.y * wobble_scale + phase),
		cos(FRAGCOORD.x * wobble_scale + phase * 1.3)
	) * wobble_strength;
	vec2 uv = SCREEN_UV + floor(wobble + 0.5) * px;
	vec2 shift = vec2(floor(aberration + 0.5), 0.0) * px;
	float r = texture(screen_texture, uv + shift).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - shift).b;
	COLOR = vec4(r, g, b, 1.0);
}
