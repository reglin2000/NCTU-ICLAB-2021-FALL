#include <iostream>
#include <vector>
#include <random>
#include <ctime>
#include <fstream>
using namespace std;

void prtbin (long long num);

const long long CRC5 = 43;
const long long CRC8 = 305;
const int PATNUM = 1000;
// const int PATNUM = 1;

int main()
{
	srand(time(0));

	ofstream infile("input.txt", ios::out);
	ofstream outfile("output.txt", ios::out);
	
	int mode;
	int CRC;
	long long two_pw = 1;
	long long two_pw_51 = 1;
	long long two_pw_54 = 1;
	long long two_pw_59 = 1;
	long long message;
	long long current_message;
	long long rand1;
	long long rand2;
	long long current_CRC;
	long long fail_num = 1;
	// long long 
	for (int i = 1; i < 60; i++)
	{
		two_pw *= 2;
		if (i == 51)
			two_pw_51 = two_pw;
		else if (i == 54)
			two_pw_54 = two_pw;
		else if (i == 59)
			two_pw_59 = two_pw;
	}
	for (int i = 1; i < 60; i++)
	{
		fail_num = fail_num << 1;
		fail_num += 1;
	}
	for (int i = 0; i < PATNUM; i++)
	{
		// mode = 0;
		// CRC = 0;
		mode = rand() % 2;
		CRC = rand() % 2;
		infile << mode << " " << CRC << endl;
		rand1 = rand();
		rand2 = rand();
		message = rand1 * rand2;
		// prtbin(message);
		if (mode == 0 && CRC == 0)
		{
			current_CRC = CRC8 << 51;
			message %= two_pw_51;
			infile << message << endl;
			current_message = message << 8;
			// prtbin(current_CRC);
			// prtbin(current_message);
		}
		else if (mode == 0 && CRC == 1)
		{
			current_CRC = CRC5 << 54;
			message %= two_pw_54;
			infile << message << endl;
			current_message = message << 5;
		}
		else if (CRC == 0)
		{
			current_CRC = CRC8 << 51;
			message %= two_pw_59;
			infile << message << endl;
			current_message = message;
		}
		else
		{
			current_CRC = CRC5 << 54;
			message %= two_pw_59;
			infile << message << endl;
			current_message = message;
		}

		if (CRC == 0)
		{
			for (int j = 59; j >= 8; j--)
			{
				if ((current_message) >> j & 1 == 1)
				{
					current_message = current_CRC ^ current_message;
				}
				current_CRC = current_CRC >> 1;
			}
		}
		else
		{
			for (int j = 59; j >= 5; j--)
			{
				if ((current_message) >> j & 1 == 1)
				{
					current_message = current_CRC ^ current_message;
				}
				current_CRC = current_CRC >> 1;
			}
		}

		if (mode == 0 && CRC == 0)
		{
			outfile << (message << 8) + current_message << endl;
		}
		else if (mode == 0 && CRC == 1)
		{
			outfile << (message << 5) + current_message << endl;
		}
		else if (mode == 1 && current_message == 0)
		{
			outfile << 0 << endl;
		}
		else if (mode == 1 && current_message != 0)
		{
			outfile << fail_num << endl;
			// cout << i << " " << current_message << endl;
		}
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
