#include <iostream>
#include <fstream>
#include <vector>
#include <ctime>
#include <random>
#include <algorithm>
using namespace std;

int pat_num = 100;

int main()
{
	srand(time(0));

	ofstream input("input.txt", ios::out);
	ofstream output("output.txt", ios::out);
	ofstream outimg("result_img.txt", ios::out);
	// ifstream infile("test.txt", ios::in);
	for (int z = 0; z < pat_num; z++)
	{
		short size = 4;
		int a = rand() % 3;
		for (int i = 0; i < a; i++)
		{
			size *= 2;
		}
		vector<vector<long long>> image(size, vector<long long >(size));
		vector<vector<long long>> templete(3, vector<long long >(3));
		vector<vector<long long>> image_temp(size, vector<long long >(1));
		vector<short> action;
		short action_size = rand()%6+2;
		vector<vector<long long>> cor_result(size, vector<long long>(size));
		short cor_size = size;
		short out_x = 0;
		short out_y = 0;
		long long max_num;

		input << size << endl;

		for (int i = 0; i < size; i++)
		{
			for (int j = 0; j < size; j++)
			{
				if (z < pat_num / 10)
				{
					image[i][j] = rand() / (RAND_MAX/100);
				}
				else if (z < pat_num * 4 / 10)
				{
					if (i == 0 && j == 0 || i == 0 && j == size || i == size && j == 0 || i == size && j == size)
						image[i][j] = rand() / (RAND_MAX/10000);
					else
						image[i][j] = rand() / (RAND_MAX/100);
					image[i][j] *= -1;
				}
				else if (z < pat_num * 7 / 10)
				{
					image[i][j] = rand() / (RAND_MAX/100);
					image[i][j] *= -1;
				}
				else
				{
					image[i][j] = rand() % 60000;
					a = rand() % 2;
					if (a == 1)
					image[i][j] *= -1;
				}
				input << image[i][j] << " ";
			}
			input << endl;
		}
		input << endl;
		for (int i = 0; i < 3; i++)
		{
			for (int j = 0; j < 3; j++)
			{
				if (z < pat_num * 7 / 10)
				{
					templete[i][j] = rand() / (RAND_MAX/100);
				}
				else
				{
					templete[i][j] = rand() % 60000;
					a = rand() % 2;
					if (a == 1)
						templete[i][j] *= -1;
				}
				input << templete[i][j] << " ";
			}
			input << endl;
		}
		input << endl;

		for (int i = 0; i < action_size - 1; i++)
		{
			action.push_back(rand()%3+1);
			input << action[i] << " ";
		}
		action.push_back(0);
		input << action.back() << endl;

		for (int i = 0; i < action_size; i++)
		{
			if (action[i] == 0)
			{
				for (int j = 0; j < cor_size; j++)
				{
					for (int k = 0; k < cor_size; k++)
					{
						if (j != 0 && j != cor_size - 1 && k != 0 && k != cor_size - 1)
							cor_result[j][k] = image[j-1][k-1] * templete[0][0] + image[j-1][k] * templete[0][1] + image[j-1][k+1] * templete[0][2] + image[j][k-1] * templete[1][0] + image[j][k] * templete[1][1] + image[j][k+1] * templete[1][2] + image[j+1][k-1] * templete[2][0] + image[j+1][k] * templete[2][1] + image[j+1][k+1] * templete[2][2];
						else if (j == 0 && k == 0)
							cor_result[j][k] = image[j][k] * templete[1][1] + image[j][k+1] * templete[1][2] + image[j+1][k] * templete[2][1] + image[j+1][k+1] * templete[2][2];
						else if (j == 0 && k == cor_size - 1)
							cor_result[j][k] = image[j][k-1] * templete[1][0] + image[j][k] * templete[1][1] + image[j+1][k-1] * templete[2][0] + image[j+1][k] * templete[2][1];
						else if (j == cor_size - 1 && k == 0)
							cor_result[j][k] = image[j-1][k] * templete[0][1] + image[j-1][k+1] * templete[0][2] + image[j][k] * templete[1][1] + image[j][k+1] * templete[1][2];
						else if (j == cor_size - 1 && k == cor_size - 1)
							cor_result[j][k] = image[j-1][k-1] * templete[0][0] + image[j-1][k] * templete[0][1] + image[j][k-1] * templete[1][0] + image[j][k] * templete[1][1];
						else if (j == 0)
							cor_result[j][k] = image[j][k-1] * templete[1][0] + image[j][k] * templete[1][1] + image[j][k+1] * templete[1][2] + image[j+1][k-1] * templete[2][0] + image[j+1][k] * templete[2][1] + image[j+1][k+1] * templete[2][2];
						else if (j == cor_size - 1)
							cor_result[j][k] = image[j-1][k-1] * templete[0][0] + image[j-1][k] * templete[0][1] + image[j-1][k+1] * templete[0][2] + image[j][k-1] * templete[1][0] + image[j][k] * templete[1][1] + image[j][k+1] * templete[1][2];
						else if (k == 0)
							cor_result[j][k] = image[j-1][k] * templete[0][1] + image[j-1][k+1] * templete[0][2] + image[j][k] * templete[1][1] + image[j][k+1] * templete[1][2] + image[j+1][k] * templete[2][1] + image[j+1][k+1] * templete[2][2];
						else if (k == cor_size - 1)
							cor_result[j][k] = image[j-1][k-1] * templete[0][0] + image[j-1][k] * templete[0][1] + image[j][k-1] * templete[1][0] + image[j][k] * templete[1][1] + image[j+1][k-1] * templete[2][0] + image[j+1][k] * templete[2][1];
						if (j == 0 && k == 0)
						{
							out_x = 0;
							out_y = 0;
							max_num = cor_result[0][0];
						}
						else if (cor_result[j][k] > max_num)
						{
							out_x = j;
							out_y = k;
							max_num = cor_result[j][k];
						}
					}

				}
			}
			else if (action[i] == 1)
			{
				if (cor_size > 4)
				{
					for (int j = 0; j < cor_size / 2; j++)
					{
						for (int k = 0; k < cor_size / 2; k++)
						{
							image[j][k] = max({image[j*2][k*2], image[j*2][k*2+1], image[j*2+1][k*2], image[j*2+1][k*2+1]});
						}
					}
					cor_size /= 2;
				}
			}
			else if (action[i] == 2)
			{
				for (int j = 0; j < cor_size / 2; j++)
				{
					for(int k = 0; k < cor_size; k++)
					{
						image_temp[k][0] = image[k][j];
						image[k][j] = image[k][cor_size - j - 1];
						image[k][cor_size - j - 1] = image_temp[k][0];
					}
				}
			}
			else if (action[i] == 3)
			{
				for (int j = 0; j < cor_size; j++)
				{
					for(int k = 0; k < cor_size; k++)
					{
						// image[j][k] = image[j][k] / 2 + 50;
						image[j][k] = (image[j][k] - (image[j][k] % 2 + 2) % 2) / 2 + 50;
					}
				}
			}
		}

		output << out_x << ' ' << out_y << endl;
		output << cor_size << endl << endl;
		if (out_x != 0 && out_x != cor_size - 1 && out_y != 0 && out_y != cor_size - 1)
		{
			output << 9 << endl;
			output << (out_x - 1)*cor_size + out_y - 1 << " ";
			output << (out_x - 1)*cor_size + out_y  << " ";
			output << (out_x - 1)*cor_size + out_y + 1 << " ";
			output << (out_x)*cor_size + out_y - 1 << " ";
			output << (out_x)*cor_size + out_y  << " ";
			output << (out_x)*cor_size + out_y + 1 << " ";
			output << (out_x + 1)*cor_size + out_y - 1 << " ";
			output << (out_x + 1)*cor_size + out_y  << " ";
			output << (out_x + 1)*cor_size + out_y + 1 << " ";
			output << endl;
		}
		else if (out_x == 0 && out_y == 0)
		{
			output << 4 << endl;
			output << (out_x)*cor_size + out_y  << " ";
			output << (out_x)*cor_size + out_y + 1 << " ";
			output << (out_x + 1)*cor_size + out_y  << " ";
			output << (out_x + 1)*cor_size + out_y + 1 << " ";
			output << endl;
		}
		else if (out_x == 0 && out_y == cor_size - 1)
		{
			output << 4 << endl;
			output << (out_x)*cor_size + out_y - 1 << " ";
			output << (out_x)*cor_size + out_y  << " ";
			output << (out_x + 1)*cor_size + out_y - 1 << " ";
			output << (out_x + 1)*cor_size + out_y  << " ";
			output << endl;
		}
		else if (out_x == cor_size - 1 && out_y == 0)
		{
			output << 4 << endl;
			output << (out_x - 1)*cor_size + out_y  << " ";
			output << (out_x - 1)*cor_size + out_y + 1 << " ";
			output << (out_x)*cor_size + out_y  << " ";
			output << (out_x)*cor_size + out_y + 1 << " ";
			output << endl;
		}
		else if (out_x == cor_size - 1 && out_y == cor_size - 1)
		{
			output << 4 << endl;
			output << (out_x - 1)*cor_size + out_y - 1 << " ";
			output << (out_x - 1)*cor_size + out_y  << " ";
			output << (out_x)*cor_size + out_y - 1 << " ";
			output << (out_x)*cor_size + out_y  << " ";
			output << endl;
		}
		else if (out_x == 0)
		{
			output << 6 << endl;
			output << (out_x)*cor_size + out_y - 1 << " ";
			output << (out_x)*cor_size + out_y  << " ";
			output << (out_x)*cor_size + out_y + 1 << " ";
			output << (out_x + 1)*cor_size + out_y - 1 << " ";
			output << (out_x + 1)*cor_size + out_y  << " ";
			output << (out_x + 1)*cor_size + out_y + 1 << " ";
			output << endl;
		}
		else if (out_x == cor_size - 1)
		{
			output << 6 << endl;
			output << (out_x - 1)*cor_size + out_y - 1 << " ";
			output << (out_x - 1)*cor_size + out_y  << " ";
			output << (out_x - 1)*cor_size + out_y + 1 << " ";
			output << (out_x)*cor_size + out_y - 1 << " ";
			output << (out_x)*cor_size + out_y  << " ";
			output << (out_x)*cor_size + out_y + 1 << " ";
			output << endl;
		}
		else if (out_y == 0)
		{
			output << 6 << endl;
			output << (out_x - 1)*cor_size + out_y  << " ";
			output << (out_x - 1)*cor_size + out_y + 1 << " ";
			output << (out_x)*cor_size + out_y  << " ";
			output << (out_x)*cor_size + out_y + 1 << " ";
			output << (out_x + 1)*cor_size + out_y  << " ";
			output << (out_x + 1)*cor_size + out_y + 1 << " ";
			output << endl;
		}
		else if (out_y == cor_size - 1)
		{
			output << 6 << endl;
			output << (out_x - 1)*cor_size + out_y - 1 << " ";
			output << (out_x - 1)*cor_size + out_y  << " ";
			output << (out_x)*cor_size + out_y - 1 << " ";
			output << (out_x)*cor_size + out_y  << " ";
			output << (out_x + 1)*cor_size + out_y - 1 << " ";
			output << (out_x + 1)*cor_size + out_y  << " ";
			output << endl;
		}

		output << endl;
		for (int i = 0; i < cor_size; i++)
		{
			for (int j = 0; j < cor_size; j++)
			{
				output << cor_result[i][j] << ' ';
			}
			output << endl;
		}
		output << endl;

		for (int i = 0; i < cor_size; i++)
		{
			for (int j = 0; j < cor_size; j++)
			{
				outimg << image[i][j] << ' ';
			}
			outimg << endl;
		}
	}
}
