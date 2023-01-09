//-----------------------------------------------------------------------------
// Demo of Test Param with share logic and name generators.
// In this test we also add random values.
// By Ari Saif
//-----------------------------------------------------------------------------
#include <algorithm>
#include <functional>
#include <string>
#include <thread>
#include <tuple>
#include <vector>

#include "gtest/gtest.h"

using ::testing::Combine;
using ::testing::Values;
using ::testing::ValuesIn;

template <class T>
void Swap(T &i, T &j) {
  T temp = i;
  i = j;
  j = temp;
}

int FindMinIndex(const std::vector<int> &input, int start_index) {
  int min_index = start_index;
  int cur_min = input[start_index];
  for (size_t i = start_index; i < input.size(); i++) {
    if (input[i] < cur_min) {
      cur_min = input[i];
      min_index = i;
    }
  }
  return min_index;
}
void SelectionSort(std::vector<int> &input) {
  for (int i = 0; i < int(input.size() - 1); i++) {
    int min_index = FindMinIndex(input, i);
    Swap(input[i], input[min_index]);
  }
}
void BubbleSort(std::vector<int> &input) {
  bool go;
  do {
    go = false;
    for (int i = 0; i < int(input.size() - 1); i++) {
      if (input[i] > input[i + 1]) {
        Swap(input[i], input[i + 1]);
        go = true;
      }
    }
  } while (go);
}

void CountSort(std::vector<int> &input) {
  if (input.size() == 0 || input.size() == 1) {
    return;
  }
  std::vector<int> out(input.size());

  int max = *std::max_element(input.begin(), input.end());

  std::vector<int> count(max + 1);

  for (auto e : input) {
    count[e]++;
  }

  // Create a prefix sum
  for (int i = 1; i <= max; ++i) {
    count[i] += count[i - 1];
  }

  // Create the output.
  for (int i = input.size() - 1; i >= 0; --i) {
    out[count[input[i]] - 1] = input[i];
    --count[input[i]];
  }

  input = out;
}

//-----------------------------------------------------------------------------
std::map<std::string, std::vector<int>> CreateInputMap() {
  std::map<std::string, std::vector<int>> input_map = {
      // Since we are using counting sort, all inputs should be non-negative
      // integers.
      {"Empty", {}},
      {"SingleElement", {1}},
      {"ReverseSort", {5, 4, 3, 2, 1}},
      {"SmallVector", {5, 3, 1, 77}},
      {"Duplicates", {4, 122, 1000, 4, 122, 1000}},
      //
  };

  const int max = 100;
  // Let's add some random vectors to input_map. The random values are between 0
  // to max;
  std::vector<int> random_vector(100);
  for (int i = 0; i < 100; i++) {
    std::srand(i);
    std::generate(random_vector.begin(), random_vector.end(),
                  []() { return std::rand() % max; });
    input_map[std::string("Random_") + std::to_string(i)] = random_vector;
  }

  return input_map;
}

std::map<std::string, std::vector<int>> input_map = CreateInputMap();

std::map<std::string, std::function<void(std::vector<int> &)>> function_map = {
    //
    {"BubbleSort", BubbleSort},
    {"SelectionSort", SelectionSort},
    {"CountSort", CountSort}
    //
};
class SortTest
    : public testing::TestWithParam<std::tuple<
          std::pair<const std::string, std::function<void(std::vector<int> &)>>,
          std::pair<const std::string, std::vector<int>>>> {};

INSTANTIATE_TEST_SUITE_P(
    SortCustomNames, SortTest,
    Combine(ValuesIn(function_map), ValuesIn(input_map)),
    [](const testing::TestParamInfo<SortTest::ParamType> &info) {
      return std::get<0>(info.param).first + "_" +
             std::get<1>(info.param).first;
    });

TEST_P(SortTest, WorksForVariousInputs) {
  auto p = GetParam();

  auto SortFunction = std::get<0>(p).second;
  auto in = std::get<1>(p).second;

  auto expected = in;
  SortFunction(in);
  std::sort(expected.begin(), expected.end());
  EXPECT_EQ(in, expected);
}
