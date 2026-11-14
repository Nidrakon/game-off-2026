// Zeitblase als Linse (Doku 2.3, Schritt 19b, ueberarbeitet 14.11.2026).
// Kennt die genaue Form der Blase (Kreis bzw. Ei) und damit an jedem Pixel
// den Abstand zum Rand (e: 0 = Mitte, 1 = Rand).
// - langsam (stage 1): grosse, traege Wellen, Woelbung zur Mitte, Farb-
//   verschiebung, kuehler Schimmer (zaehfluessig)
// - schnell (stage 2): zitternde Bildzeilen, Unschaerfe nach aussen, starke
//   Rot-Blau-Trennung, warmer Schimmer (hektisch)
// - Rand (alle Stufen): Bild wird zur Randlinie hin gezogen, darauf ein
//   schillernder Seifenblasen-Film; auf "normal" nur schwach.
// Mischfarben sind erlaubt (Ausnahme Zeitblase, Doku 1.7). Alle Laengen in
// Pixeln; das Skript setzt Form, Phase und Staerken.
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
// Form: Radius (hinten, Breite), Abstand der Spitze, Richtung der Spitze.
uniform float radius = 80.0;
uniform float front_length = 80.0;
uniform vec2 direction = vec2(1.0, 0.0);
// 0 = normal, 1 = langsam, 2 = schnell
uniform int stage = 0;
uniform float phase = 0.0;
// Gesamtstaerke der Effekte im Inneren (0 bis 1; auf normal 0).
uniform float strength = 1.0;
// langsam
uniform float slow_wobble = 4.0;
uniform float slow_bulge = 10.0;
uniform float slow_aberration = 2.0;
// schnell
uniform float fast_jitter = 3.0;
uniform float fast_blur = 10.0;
uniform float fast_aberration = 4.0;
// Rand
uniform float rim_pull = 6.0;
uniform float rim_width = 0.16;
uniform float rim_film = 0.55;
uniform float rim_strength = 1.0;

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

// Abstand zum Rand: 0 in der Mitte, 1 auf dem Rand.
float edge(vec2 p) {
	vec2 side = vec2(-direction.y, direction.x);
	float along = dot(p, direction);
	float across = dot(p, side);
	if (along > 0.0) {
		return length(vec2(along / front_length, across / radius));
	}
	return length(p) / radius;
}

// Regenbogen fuer den Seifenblasen-Film
vec3 rainbow(float t) {
	return 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 0.33, 0.67)));
}

float hash(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE;
	float e = edge(local_pos);
	vec2 radial = length(local_pos) > 0.001 ? normalize(local_pos) : vec2(0.0);
	vec2 offset = vec2(0.0);
	float ab = 0.0;
	vec3 tint = vec3(1.0);
	float blur = 0.0;

	if (stage == 1) {
		// zaehfluessig: Woelbung zur Mitte und grosse, langsame Ringwellen
		offset -= radial * slow_bulge * (1.0 - e * e) * strength;
		float ripple = sin(e * 9.0 - phase) + 0.5 * sin(local_pos.y * 0.06 + phase * 0.7);
		offset += radial * ripple * slow_wobble * strength;
		ab = slow_aberration * strength;
		tint = mix(vec3(1.0), vec3(0.82, 0.93, 1.18), 0.35 * strength);
	} else if (stage == 2) {
		// hektisch: Zeilen zittern, Unschaerfe nach aussen
		float row = floor(FRAGCOORD.y / 3.0);
		float tick = floor(phase * 2.0);
		offset.x += (hash(row + tick * 13.0) - 0.5) * 2.0 * fast_jitter * strength;
		offset += radial * sin(e * 22.0 - phase * 3.0) * 1.5 * strength;
		blur = fast_blur * strength;
		ab = fast_aberration * strength;
		tint = mix(vec3(1.0), vec3(1.18, 1.0, 0.82), 0.3 * strength);
	}

	// Rand: zur Randlinie hin ziehen (wie eine Linse am Blasenrand)
	float rim = smoothstep(1.0 - rim_width, 1.0, e);
	offset += radial * rim * rim * rim_pull * rim_strength;

	vec2 uv = SCREEN_UV + floor(offset + 0.5) * px;
	vec2 shift = vec2(floor(ab + 0.5), 0.0) * px;
	vec3 col;
	if (blur > 0.5) {
		// Unschaerfe: mehrere Proben entlang der Richtung nach aussen
		vec3 acc = vec3(0.0);
		for (int i = 0; i < 4; i++) {
			vec2 step_uv = uv - radial * px * blur * float(i) / 3.0;
			acc.r += texture(screen_texture, step_uv + shift).r;
			acc.g += texture(screen_texture, step_uv).g;
			acc.b += texture(screen_texture, step_uv - shift).b;
		}
		col = acc / 4.0;
	} else {
		col = vec3(texture(screen_texture, uv + shift).r, texture(screen_texture, uv).g, texture(screen_texture, uv - shift).b);
	}
	col *= tint;

	// Seifenblasen-Film: duenner, schillernder Rand
	float film = smoothstep(0.9, 0.985, e) * (1.0 - smoothstep(0.985, 1.0, e) * 0.5);
	float angle = atan(local_pos.y, local_pos.x);
	vec3 iris = rainbow(angle / 6.28318 + e * 2.5 + phase * 0.04);
	col = mix(col, col + iris * 0.6, film * rim_film * rim_strength);
	COLOR = vec4(col, 1.0);
}
