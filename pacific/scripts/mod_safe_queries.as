#include "helpers.as"

// Query lists can contain ID-only records, and entities may disappear between
// the list and detail queries. Never pass optional/unchecked text to the
// vanilla stringToVector3, which indexes three tokens unconditionally.
bool modNumberToken(string value) {
    if (value.length() == 0 || value.length() > 64) return false;
    uint i = 0;
    string c = value.substr(i, 1);
    if (c == "+" || c == "-") ++i;
    bool digits = false;
    while (i < value.length() &&
           "0123456789".findFirst(value.substr(i, 1)) >= 0) {
        digits = true;
        ++i;
    }
    if (i < value.length() && value.substr(i, 1) == ".") {
        ++i;
        while (i < value.length() &&
               "0123456789".findFirst(value.substr(i, 1)) >= 0) {
            digits = true;
            ++i;
        }
    }
    if (!digits) return false;
    if (i < value.length() &&
        (value.substr(i, 1) == "e" || value.substr(i, 1) == "E")) {
        ++i;
        if (i < value.length() &&
            (value.substr(i, 1) == "+" || value.substr(i, 1) == "-")) ++i;
        uint exponentStart = i;
        while (i < value.length() &&
               "0123456789".findFirst(value.substr(i, 1)) >= 0) ++i;
        if (i == exponentStart) return false;
    }
    return i == value.length();
}

bool modTryVector(string text, Vector3 &out result) {
    if (text.length() == 0 || text.length() > 256) return false;
    array<float> values;
    string token;
    for (uint i = 0; i <= text.length(); ++i) {
        string c = i < text.length() ? text.substr(i, 1) : " ";
        if (c == " " || c == "\t" || c == "\r" || c == "\n") {
            if (token == "") continue;
            if (values.length() >= 3 || !modNumberToken(token)) return false;
            float value = parseFloat(token);
            // The range test also rejects NaN and infinities.
            if (!(value >= -1000000.0f && value <= 1000000.0f)) return false;
            values.insertLast(value);
            token = "";
        } else {
            token += c;
        }
    }
    if (values.length() != 3) return false;
    result.set(values[0], values[1], values[2]);
    return true;
}

bool modTryVectorAttribute(const XmlElement@ element, string name,
                           Vector3 &out result) {
    return element !is null && element.hasAttribute(name) &&
        modTryVector(element.getStringAttribute(name), result);
}

int modIntAttribute(const XmlElement@ element, string name, int fallback = -1) {
    if (element is null || !element.hasAttribute(name)) return fallback;
    return element.getIntAttribute(name);
}
