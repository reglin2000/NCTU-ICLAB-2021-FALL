#include <iostream>
#include <vector>
#include <random>
#include <ctime>
#include <fstream>
using namespace std;

void prtbin (long long num);

const int PATNUM = 1000;
// const int PATNUM = 1;

int main()
{
	srand(time(0));

	ofstream infile("input.txt", ios::out);
	ofstream outfile("output.txt", ios::out);

	vector<int> in_data(9);
	int num1;
	int num2;
	int neg;
	int in_mode;
	int max_num;
	int min_num;
	int max_sequence;
	int max_position;
	int cur_sequence;

	infile << PATNUM << endl << endl;

	for (int z = 0; z < PATNUM; z++)
	{
		in_mode = rand() % 8;
		infile << in_mode << endl;

		if (in_mode & 1)
		{
			for (int i = 0; i < 9; i++)
			{
				num1 = rand() % 10;
				num2 = rand() % 10;
				neg = rand() % 2;
				if (neg == 0)
				{
					in_data[i] = (num1)*10 + num2;
					infile << 0;
				}
				else
				{
					in_data[i] = (-1) * ((num1)*10 + num2);
					infile << 1;
				}
				num1 += 3;
				num2 += 3;
				for (int j = 3; j >= 0; j--)
					infile << ((num1 >> j) & 1);
				for (int j = 3; j >= 0; j--)
					infile << ((num2 >> j) & 1);
				infile << endl;
				{
					// cout << in_data[i] << endl;
					// cout << num1 << " " << num2 << endl;
					// for (int j = 3; j >= 0; j--)
					// 	cout << ((num1 >> j) & 1);
					// for (int j = 3; j >= 0; j--)
					// 	cout << ((num2 >> j) & 1);
					// cout << endl;
				}
			}
		}
		else
		{
			for (int i = 0; i < 9; i++)
			{
				neg = rand() % 2;
				if (neg == 0)
				{
					in_data[i] = rand() % 256;
					infile << 0;
				}
				else
				{
					in_data[i] = (-1) * (rand() % 256);
					infile << 1;
				}
				for (int j = 8; j >= 0; j--)
					infile << ((in_data[i] >> j) & 1);
				infile << endl;
				{
					cout << in_data[i] << endl;
					for (int j = 8; j >= 0; j--)
						cout << ((in_data[i] >> j) & 1);
					cout << endl;
				}
			}
		}

		infile << endl;

		if ((in_mode >> 1) & 1)
		{
			max_num = INT_MIN;
			min_num = INT_MAX;
			for (int i = 0; i < 9; i++)
			{
				if (in_data[i] > max_num)
					max_num = in_data[i];
				if (in_data[i] < min_num)
					min_num = in_data[i];
			}
			for (int i = 0; i < 9; i++)
				in_data[i] -= (max_num+min_num) / 2;
		}

		if ((in_mode >> 2) & 1)
		{
			for (int i = 1; i < 9; i++)
			{
				in_data[i] = (in_data[i-1]*2 + in_data[i]) / 3;
			}
		}

		max_sequence = INT_MIN;
		max_position = 0;
		for (int i = 2; i < 9; i++)
		{
			cur_sequence = in_data[i] + in_data[i - 1] + in_data[i - 2];
			if (cur_sequence > max_sequence)
			{
				max_sequence = cur_sequence;
				max_position = i;
			}
		}

		outfile << in_data[max_position-2] << endl;
		outfile << in_data[max_position-1] << endl;
		outfile << in_data[max_position] << endl;
		outfile << endl;
	}
	
}

void prtbin (long long num)
{
	for (int i = 0; i < 64; i--)
	{
		cout << ((num << i) & 1);
	}
	cout << endl;
	return;
}
