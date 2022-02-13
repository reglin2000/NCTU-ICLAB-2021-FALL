#include <iostream>
#include <fstream>
#include <random>
#include <vector>
#include <ctime>
using namespace std;

int gf2k_add (int in1, int in2);
int gf2k_mult(int in1, int in2, int poly);
int gf2k_div(int in1, int in2, int poly);

int mode = 3;
const int PAT_NUM = 1000;

int main()
{
	srand(time(0));

	ofstream input("input_IP.txt", ios::out);
	ofstream output("output_IP.txt", ios::out);
	
	int in1;
	int in2;
	int poly;
	int degree;
	int exp_2[10] = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512};
	int poly_table[20] = {3, 7, 11, 13, 19, 25, 37, 41, 47, 55, 59, 61, 97, 115, 171, 193, 229, 285, 357, 397};
	for (int i = 0; i < PAT_NUM; i++)
	{
		// mode = rand() % 4;
		mode = 3;
		// degree = rand() % 7 + 2;
		degree = 8;
		in1 = rand() % (exp_2[degree] - 1);
		in2 = rand() % (exp_2[degree] - 1) + 1;
		poly = rand() % (exp_2[degree + 1] - exp_2[degree]) + exp_2[degree];
		if (degree == 2)
			poly = 7;
		else if (degree == 3)
		{
			poly = rand() % 2;
			poly = poly_table[poly + 2];
		}
		else if (degree == 4)
		{
			poly = rand() % 2;
			poly = poly_table[poly + 4];
		}
		else if (degree == 5)
		{
			poly = rand() % 6;
			poly = poly_table[poly + 6];
		}
		else if (degree == 6)
		{
			poly = rand() % 2;
			poly = poly_table[poly + 12];
		}
		else if (degree == 7)
		{
			poly = rand() % 3;
			poly = poly_table[poly + 14];
		}
		else if (degree == 8)
		{
			poly = rand() % 3;
			poly = poly_table[poly + 17];
		}

		input << mode << endl;
		input << degree << endl;
		input << in1 << " " << in2 << endl;
		input << poly << endl << endl;
		
		if (mode == 0 || mode == 1)
		{
			output << gf2k_add(in1, in2) << endl;
		}
		else if (mode == 2)
		{
			output << gf2k_mult(in1, in2, poly) << endl;
		}
		else if (mode == 3)
		{
			output << gf2k_div(in1, in2, poly) << endl;
		}
	}
}

int gf2k_add (int in1, int in2)
{
	int result = in1 ^ in2;
	return result;
}

int gf2k_mult(int in1, int in2, int poly)
{
	int result = 0;
	int max_poly = 0;
	
	for (int i = 0; i < 32; i++)
		if ((poly>>i) & 1 == 1)
			max_poly = i;

	for (int i = 0; i < 32; i++)
	{
		if ((in2 >> i) & 1 == 1)
		{
			result = gf2k_add((in1<<i), result);
		}
	}
	for (int i = 31; i >= 0; i--)
	{
		if (i < max_poly)
			break;
		if ((result >> i) & 1 == 1)
		{
			result = gf2k_add(result, (poly<<(i-max_poly)));
		}
	}
	return result;
}

int gf2k_div(int in1, int in2, int poly)
{
	int dn = poly;
	int dr = in2;
	int r = INT_MAX;
	int max_dn = 0;
	int max_dr = 0;
	int MQ = 1;
	int mql = 1;
	int mqh = 0;

	while(r != 1 && r != 0)
	{
		bool dn_bin;
		bool dr_bin;
		for (int i = 0; i < 32; i++)
		{
			dn_bin = (dn>>i) & 1;
			dr_bin = (dr>>i) & 1;
			if (dn_bin == 1)
				max_dn = i;
			if (dr_bin == 1)
				max_dr = i;

		}
		r = gf2k_add(dn, (dr<<(max_dn-max_dr)));
		MQ = gf2k_add(mqh, (mql<<(max_dn-max_dr)));

		if (dr >= r)
		{
			dn = dr;
			dr = r;
			mqh = mql;
			mql = MQ;
		}
		else
		{
			dn = r;
			dr = dr;
			mqh = MQ;
			mql = mql;
		}
		
	}
	return gf2k_mult(MQ, in1, poly);
}
