//+------------------------------------------------------------------+
//|                                                     Helper_1.mq4 |
//|                                                       Jeniacomru |
//|                                                          http:// |
//+------------------------------------------------------------------+
#property copyright "Jeniacomru"
#property link      "http://"

//--- input parameters
extern string    b1="Стоплось и профит";
extern bool      SetStopLevels = True;
extern int       TP=50;
extern int       SL=50;

extern string    b2="Безубыток";
extern bool      BU = True;
extern int       BULevel = 25;
extern int       BUsize = 2;

extern string    b3="Трал";
extern bool      PositionTrailing = True;
extern bool      ProfitTrailing   = True;
extern int       TrailingStop     = 50; 
extern int       TrailingStep     = 2; 

double Point_;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   if (Digits <= 3) Point_ = 0.01;
   else Point_ = 0.0001;
   
   if(SetStopLevels) SetSLTP();
   if(BU) BU();
   if(PositionTrailing) tral();
//----
   return(0);
  }

//+------------------------------------------------------------------+
void SetSLTP() {
  double sl = 0, tp = 0;
  for (int i=0; i<OrdersTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==Symbol()) {
       if (OrderType()==OP_BUY  && (OrderStopLoss() == 0 && OrderTakeProfit() == 0)) 
        {
         if(SL>0) sl = OrderOpenPrice() - SL*Point_;
         if(TP>0) tp = OrderOpenPrice() + TP*Point_;
         ModifyStops(sl, tp);
        }
       if (OrderType()==OP_SELL && (OrderStopLoss() == 0 && OrderTakeProfit() == 0)) 
        {
         if(SL>0) sl = OrderOpenPrice() + SL*Point_;
         if(TP>0) tp = OrderOpenPrice() - TP*Point_;
         ModifyStops(sl, tp);
        }
      }
    }
  }
}

//+------------------------------------------------------------------+
void tral() {
  for (int i=0; i<OrdersTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==Symbol()) {
        TrailingPositions(TrailingStop);
      }
    }
  }
}

//Трал
void TrailingPositions(int TrailingStop) {
  double pBid, pAsk, pp;

  pp = Point_;
  if (OrderType()==OP_BUY) {
    pBid = MarketInfo(OrderSymbol(), MODE_BID);
    if (!ProfitTrailing || (pBid-OrderOpenPrice())>TrailingStop*pp) {
      if (OrderStopLoss()<pBid-(TrailingStop+TrailingStep-1)*pp) {
        ModifyStopLoss(pBid-TrailingStop*pp);
        return;
      }
    }
  }
  if (OrderType()==OP_SELL) {
    pAsk = MarketInfo(OrderSymbol(), MODE_ASK);
    if (!ProfitTrailing || OrderOpenPrice()-pAsk>TrailingStop*pp) {
      if (OrderStopLoss()>pAsk+(TrailingStop+TrailingStep-1)*pp || OrderStopLoss()==0) {
        ModifyStopLoss(pAsk+TrailingStop*pp);
        return;
      }
    }
  }
}

//+----------------------------------------------------------------------------+
void BU()
{
  for (int i=0; i<OrdersTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==Symbol())
      {
       BU_();
      }
    }
  }
}

//+----------------------------------------------------------------------------+
void BU_()
{
  double pa, pb, pp;
  pp=Point_;
  
  if (OrderType()==OP_BUY) {
    RefreshRates();
    pb=MarketInfo(OrderSymbol(), MODE_BID);

      if (pb>OrderOpenPrice()+(BULevel-1)*pp && (OrderStopLoss()<OrderOpenPrice())) {
        ModifyStopLoss(OrderOpenPrice()+BUsize*pp);
        return;
      }
    }

  if (OrderType()==OP_SELL) {
    RefreshRates();
    pa=MarketInfo(OrderSymbol(), MODE_ASK);

      if (pa<OrderOpenPrice()-(BULevel-1)*pp && (OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0)) {
        ModifyStopLoss(OrderOpenPrice()-BUsize*pp);
        return;
      }
    }

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Перенос уровня StopLoss                                          |
//+------------------------------------------------------------------+
void ModifyStopLoss(double ldStopLoss) {
  bool fm;

  fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,Aqua);
}
//+------------------------------------------------------------------+
void ModifyStops(double ldStopLoss, double ldTP) {
  bool fm;
  double sl = 0, tp = 0;
  if(ldStopLoss>0) sl = ldStopLoss;
  if(ldTP>0) tp = ldTP;
  fm=OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,Aqua);
}
//+------------------------------------------------------------------+

