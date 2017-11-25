#define p (userRealBalance <= INITIAL_USER_REAL_BALANCE + INITIAL_USER_CONTRACT_BALANCE)
#define INITIAL_CONTRACT_BALANCE 100
#define INITIAL_USER_CONTRACT_BALANCE 10

#define INITIAL_USER_REAL_BALANCE 0
ltl p1 {always p}

mtype = {WTH}

int contractBalance
int userContractBalance
int userRealBalance

proctype user(chan cmdChannel, moneyChannel)
{
    int amount
    do
      :: cmdChannel!WTH,1 -> moneyChannel?amount
    od    
}

proctype contract(chan cmdChannel, moneyChannel)
{
    int amount
    do
      :: cmdChannel?WTH,amount ->
        if
          :: userContractBalance >= amount ->
            moneyChannel!amount
            userRealBalance = userRealBalance + amount
            contractBalance = contractBalance - amount
            run user(cmdChannel, moneyChannel)
            run contract(cmdChannel, moneyChannel)
            userContractBalance = userContractBalance - amount
          :: else -> skip
        fi
    od
}

init 
{
    chan cmdChannel = [0] of {mtype, int}
    chan moneyChannel = [0] of {int}
    contractBalance = INITIAL_CONTRACT_BALANCE
    userContractBalance = INITIAL_USER_CONTRACT_BALANCE
    userRealBalance = INITIAL_USER_REAL_BALANCE
    run contract(cmdChannel, moneyChannel);
    run user(cmdChannel, moneyChannel);
}
