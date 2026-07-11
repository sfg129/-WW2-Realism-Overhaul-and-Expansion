// internal
// --------------------------------------------
class Vector2 {
	// --------------------------------------------
	Vector2() {
		m_values = array<float>(2, 0.0f);
	}

	// --------------------------------------------
	Vector2(float x, float y) {
		m_values = array<float>(2, 0.0f);
		set(x,y);
	}

	// --------------------------------------------
	Vector2 scale(float scalar) const {
		Vector2 d();
		for (uint i = 0; i < m_values.size(); ++i) {
			d.m_values[i] = m_values[i] * scalar;
		}
		return d;
	}

	// --------------------------------------------
	Vector2 add(const Vector2@ v2) const {
		Vector2 d();
		for (uint i = 0; i < m_values.size(); ++i) {
			d.m_values[i] = m_values[i] + v2.m_values[i];
		}
		return d;
	}

	// --------------------------------------------
	Vector2 subtract(const Vector2@ v2) const {
		Vector2 d();
		for (uint i = 0; i < m_values.size(); ++i) {
			d.m_values[i] = m_values[i] - v2.m_values[i];
		}
		return d;
	}

	// --------------------------------------------
	void set(float x, float y) {
		m_values[0] = x;
		m_values[1] = y;
	}

	// --------------------------------------------
	string toString() const {
		array<string> strings;
		for (uint i = 0; i < m_values.size(); ++i) {
			string s = formatFloat(m_values[i], '', 0, 5);
			strings.insertLast(s);
		}
		return join(strings, " ");
	}

	// [] usage
	// --------------------------------------------
    float get_opIndex(int i) const { 
		return m_values[i]; 
	}

	// --------------------------------------------
	array<float> m_values;
};

