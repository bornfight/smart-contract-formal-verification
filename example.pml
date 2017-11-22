#define p       (contractBalance >= 0)
ltl p1 {always p}

mtype = {REQ, CLM, DEP}
int ownerPid

int contractBalance
int balances[5] = {0}
int allowance[5] = {0}

#define currentBalance balances[_pid]

proctype user(chan channel; int balance)
{
    int oldBalance, oldContractBalance, status
    chan requestChannel = [0] of {int, int}
    chan depositChannel = [0] of {int, int}
    currentBalance = balance;
    do
      :: skip ->
        channel!REQ,requestChannel
        oldBalance = currentBalance
        oldContractBalance = contractBalance;
        requestChannel!1,_pid
        requestChannel?status,0
        if 
          :: status == 0 -> 
            assert(oldBalance + 1 == currentBalance)
            assert(contractBalance == oldContractBalance - 1)
          :: status == 1 -> 
            assert(oldBalance == currentBalance)
            assert(contractBalance == oldContractBalance)
        fi
      :: skip ->
        channel!DEP,depositChannel
        oldBalance = currentBalance
        oldContractBalance = contractBalance;
        depositChannel!1,_pid
        depositChannel?status,0
        if
          :: status == 0 -> 
            assert(currentBalance == oldBalance - 1)
            assert(contractBalance == oldContractBalance + 1)
          :: else -> 
            assert(currentBalance == oldBalance)
            assert(contractBalance == oldContractBalance)
        fi
      :: currentBalance >= 2 -> break
    od
}

proctype contract(chan channel; int balance)
{ 
    chan secondaryChannel;
    int amount, mpid;
    contractBalance = balance
    do
      :: channel?REQ,secondaryChannel ->
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
        run contract(channel, 1000);
        ownerPid = run user(channel, 100);
        run user(channel, 0);
    }
}
never  {    /* []p */
accept_init:
T0_init:
	do
	:: ((p)) -> goto T0_init
	od;
}
