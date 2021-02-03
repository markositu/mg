#include <cassert>
#include <cstdio>
#include <cstdlib>
#include "line.h"
#include "constants.h"
#include "tools.h"

Line::Line() : m_O(Vector3::ZERO), m_d(Vector3::UNIT_Y) {}
Line::Line(const Vector3 & o, const Vector3 & d) : m_O(o), m_d(d) {}
Line::Line(const Line & line) : m_O(line.m_O), m_d(line.m_d) {}

Line & Line::operator=(const Line & line) {
	if (&line != this) {
		m_O = line.m_O;
		m_d = line.m_d;
	}
	return *this;
}

// @@ TODO: Set line to pass through two points A and B
//
// Note: Check than A and B are not too close!

void Line::setFromAtoB(const Vector3 & A, const Vector3 & B) {
Vector3 vecDir=B-A;
	if(vecDir.length()> vecDir.epsilon){
        m_O=A;
        m_d=vecDir;
    }
}

// @@ TODO: Give the point corresponding to parameter u

Vector3 Line::at(float u) const {
	Vector3 res;
	res=m_O+u*m_d;
	return res;
}

// @@ TODO: Calculate the parameter 'u0' of the line point nearest to P
//
// u0 = m_d*(P-m_o) / m_d*m_d , where * == dot product

float Line::paramDistance(const Vector3 & P) const {
	float res = 0.0f;
	if(!m_d.isZero()){
		 res = m_d.dot(P-m_O)/m_d.dot(m_d);
	}

	return res;
}

// @@ TODO: Calculate the minimum distance 'dist' from line to P
//
// dist = ||P - (m_o + u0*m_d)||
// Where u0 = paramDistance(P)

float Line::distance(const Vector3 & P) const {
	Vector3 res = P -(this->at(this->paramDistance(P)));
	return res.length();
}

void Line::print() const {
	printf("O:");
	m_O.print();
	printf(" d:");
	m_d.print();
	printf("\n");
}
