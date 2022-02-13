#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <ctime>
#include <random>
using namespace std;

int pat_num = 10000;

int main()
{
	int mode = 0;
	int w;
	int vgs;
	int vds;
	vector<int> result(6);
	int pattern_num = 168 * 4;
	int out;

	srand(time(0));

	ofstream input("input.txt", ios::out);
	ofstream output("output.txt", ios::out);
	input << pat_num << endl << endl;

	int table[392][3];
	int index = 0;
	for (int i = 1; i < 8; i++)
	{
		for (int j = 1; j < 8; j++)
		{
			for (int k = 0; k < 8; k++)
			{
				table[index][0] = i;
				table[index][1] = j;
				table[index][2] = k;
				++index;
			}
		}
	}
	cout << index << endl;

	for (int i = 0; i < pat_num; i++)
	{
		mode = rand() % 4;
		input << mode << endl;
		for (int j = 0; j < 6; j++)
		{
			w = rand() % 7 + 1;
			vgs = rand() % 7 + 1;
			vds = rand() % 8;
			input << w << ' ' << vgs << ' ' << vds << endl;
			if (mode == 1 || mode == 3)
			{
				if (vgs - 1 > vds)
					result[j] = (w*(2*(vgs-1)*vds - vds*vds)) / 3;
				else
					result[j] = (w*(vgs-1)*(vgs-1)) / 3;
			}
			else
			{
				if (vgs - 1 > vds)
					result[j] = 2*w*vds/3;
				else
					result[j] = 2*w*(vgs - 1)/3;
			}
			index++;
		}
		input << endl;
		sort(result.begin(), result.end());
		switch (mode)
		{
			case 0:
				out = result[0] + result[1] + result[2];
				break;
			case 1:
				out = 3 * result[2] + 4 * result[1] + 5 * result[0];
				break;
			case 2:
				out = result[3] + result[4] + result[5];
				break;
			case 3:
				out = 3 * result[5] + 4 * result[4] + 5 * result[3];
				break;
		}
		output << out << endl;
	}
}
