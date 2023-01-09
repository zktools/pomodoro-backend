// GMock Demo
// Mocking a non-pointer member variable of a non-virtual class.
// By Ari Saif
//-----------------------------------------------------------------------------
#include <exception>
#include <iostream>
#include <vector>

#include "gmock/gmock.h"
#include "gtest/gtest.h"

using ::testing::Return;
//-----------------------------------------------------------------------------
class MockBankServer {
 public:
  MOCK_METHOD(void, Connect, (), ());
  MOCK_METHOD(void, Disconnect, (), ());
  MOCK_METHOD(void, Credit, (int, int), ());
  MOCK_METHOD(void, Debit, (int, int), ());
  MOCK_METHOD(int, GetBalance, (int), (const));
};
//-----------------------------------------------------------------------------
// Template ATM Machine
template <class BankServer>
class AtmMachine {
  // The member variable is NOT a pointer!
  BankServer bankServer_;

 public:
  AtmMachine() {}

  // Provide a getter for our non-pointer member variable
  BankServer* GetBankServer() { return &bankServer_; }

  bool Withdraw(int account_number, int value) {
    bool result = false;
    bankServer_.Connect();
    auto available_balance = bankServer_.GetBalance(account_number);
    if (available_balance >= value) {
      bankServer_.Debit(account_number, value);
      result = true;
    }

    bankServer_.Disconnect();
    return result;
  }
};
//-----------------------------------------------------------------------------
TEST(AtmMachine, CanWithdrawSimple) {
  // Arrange
  const int account_number = 1234;
  const int withdraw_value = 1000;

  AtmMachine<MockBankServer> atm_machine;

  // Use the getter to get a pointer to the mocked member varibale:
  MockBankServer* mock_bankserver = atm_machine.GetBankServer();

  // Using the pointer to the mocked member variable, we specify what should
  // happen:
  ON_CALL(*mock_bankserver, GetBalance(account_number))
      .WillByDefault(Return(2000));

  // Act
  bool withdraw_result = atm_machine.Withdraw(account_number, withdraw_value);

  // Assert
  EXPECT_TRUE(withdraw_result);
}
//-----------------------------------------------------------------------------
TEST(AtmMachine, CantWithdrawWhenNotEnoughMoney) {
  // Arrange
  const int account_number = 1234;
  const int withdraw_value = 1000;

  AtmMachine<MockBankServer> atm_machine;

  // Use the getter to get a pointer to the mocked member varibale:
  MockBankServer* mock_bankserver = atm_machine.GetBankServer();

  // Using the pointer to the mocked member variable, we specify what should
  // happen:
  ON_CALL(*mock_bankserver, GetBalance(account_number))
      .WillByDefault(Return(2));

  // Act
  bool withdraw_result = atm_machine.Withdraw(account_number, withdraw_value);

  // Assert
  EXPECT_FALSE(withdraw_result);
}