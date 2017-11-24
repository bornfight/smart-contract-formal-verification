#define p (contractBalance >= 0)
ltl p1 {always p}

#define N 5
#define WITHDRAW_AMOUNT 5
#define DEPOSIT_AMOUNT 1

mtype = {WTH, DEP, CLM}
int ownerPid

int contractBalance
int contractAllowance = 100
int balances[N + 1]
int userAllowances[N + 1]

#define currentBalance balances[_pid]

proctype user(chan channel; int balance)
{
    int oldBalance, oldContractBalance, status
    chan requestChannel = [0] of {int, int}
    chan depositChannel = [0] of {int, int}
    currentBalance = balance;
    do
      :: skip ->
        channel!WTH,requestChannel
        oldBalance = currentBalance
        oldContractBalance = contractBalance;
        requestChannel!WITHDRAW_AMOUNT,_pid
        requestChannel?status,0
        if 
          :: status == 0 -> 
            assert(oldBalance + WITHDRAW_AMOUNT == currentBalance)
            assert(contractBalance == oldContractBalance - WITHDRAW_AMOUNT)
          :: status == 1 -> 
            assert(oldBalance == currentBalance)
            assert(contractBalance == oldContractBalance)
        fi
      :: skip ->
        channel!DEP,depositChannel
        oldBalance = currentBalance
        oldContractBalance = contractBalance;
        depositChannel!DEPOSIT_AMOUNT,_pid
        depositChannel?status,0
        if
          :: status == 0 -> 
            assert(currentBalance == oldBalance - DEPOSIT_AMOUNT)
            assert(contractBalance == oldContractBalance + DEPOSIT_AMOUNT)
          :: else -> 
            assert(currentBalance == oldBalance)
            assert(contractBalance == oldContractBalance)
        fi
    od
}

proctype contract(chan channel; int balance)
{ 
    chan secondaryChannel;
    int amount, mpid;
    contractBalance = balance
    do
      :: channel?WTH,secondaryChannel ->
        secondaryChannel?amount,mpid
        if
          :: contractBalance >= amount -> 
            balances[mpid] = balances[mpid] + amount
            contractBalance = contractBalance - amount
            secondaryChannel!0,0
          :: else -> 
            secondaryChannel!1,0
        fi
      :: channel?DEP,secondaryChannel -> 
          secondaryChannel?amount,mpid
          if
            :: balances[mpid] >= amount ->
              balances[mpid] = balances[mpid] - amount;
              contractBalance = contractBalance + amount;
              secondaryChannel!0,0
            :: else -> secondaryChannel!1,0
          fi
    od
}

init {
    chan channel = [0] of {mtype, chan};
    atomic {
        run contract(channel, 0);
        ownerPid = run user(channel, 100);
        run user(channel, 0);
    }
}
