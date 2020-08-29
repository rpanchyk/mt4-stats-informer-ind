//+------------------------------------------------------------------+
//|                                                StatsInformer.mq4 |
//|                                         Copyright 2020, GoNaMore |
//|                Based on 'stat informer2.mq4' from NeO since 2012 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, GoNaMore"
#property link      "https://github.com/gonamore/fxsi"
#property version   "1.1"
#property strict
#property indicator_chart_window

// constants
string label = "label_stats_informer_";
enum Position
  {
   Left = CORNER_LEFT_UPPER, //Слева
   Right = CORNER_RIGHT_UPPER //Справа
  };

// config
extern string fontFamily = "Tahoma"; //Шрифт
extern color fontColor = clrLightGray; //Цвет шрифта
extern color separatorColor = clrGold; //Цвет разделителя
extern int fontSize = 10; //Размер шрифта
extern Position position = Left; //Отображение
extern int indentX = 15; //Отступ сбоку
extern int indentY = 55; //Отступ сверху
extern int indentLine = 17; //Отступ между строк
extern bool isCent = true; //Центовый счет?
extern string currency = "$"; //Валюта счета

// runtime
int rowCounter = 0;
double drawdown;
double maxDrawdown;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Clean();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   Calculate();

   AddRow("----------------------------------", true);
   AddRow("Сервер: " + AccountServer());
   AddRow("----------------------------------", true);
   AddRow("              Прибыль             ");
   AddRow("----------------------------------", true);
   AddRow("Сегодня: " + DoubleToStr(ProfitToday(), 2) + " " + currency);
   AddRow("Вчера: " + DoubleToStr(ProfitForDay(1), 2) + " " + currency);
   AddRow("Неделя: " + DoubleToStr(ProfitWeek(), 2) + " " + currency);
   AddRow("Месяц: " + DoubleToStr(ProfitMonth(), 2) + " " + currency);
   AddRow("----------------------------------", true);
   AddRow("Баланс: " + DoubleToStr(Balance(), 2) + " " + currency);
   AddRow("Средства: " + DoubleToStr(Equity(), 2) + " " + currency);
   AddRow("Свободно: " + DoubleToStr(FreeMargin(), 2) + " " + currency);
   AddRow("Прибыль: " + DoubleToStr(Profit(), 2) + " " + currency);
   AddRow("Просадка тек.: " + DoubleToStr(drawdown, 2) + " %");
   AddRow("Просадка макс.: " + DoubleToStr(maxDrawdown, 2) + " %");
   AddRow("----------------------------------", true);
   AddRow("Плечо: 1:" + DoubleToStr(AccountLeverage(), 0));
   AddRow("Спред: " + DoubleToStr(NormalizeDouble((Ask - Bid)/Point, 1), 1));
   AddRow("----------------------------------", true);

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddRow(string value, bool isSeparator = false)
  {
   rowCounter++;
   string objectName = label + IntegerToString(rowCounter);

   if(ObjectFind(objectName) == -1)
     {
      ObjectCreate(objectName, OBJ_LABEL, 0, 0, 0);
      ObjectSet(objectName, OBJPROP_CORNER, position);
      ObjectSet(objectName, OBJPROP_XDISTANCE, indentX);
      ObjectSet(objectName, OBJPROP_BGCOLOR, clrWhite);


      double y;
      if(rowCounter == 1)
        {
         y = indentY;
        }
      else
        {
         y = indentY + (indentLine * (rowCounter - 1));
        }
      ObjectSet(objectName, OBJPROP_YDISTANCE, y);
     }

   int colour = fontColor;
   if(isSeparator)
     {
      colour = separatorColor;
     }

   ObjectSetText(objectName, value, fontSize, fontFamily, colour);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProfitForDay(int day)
  {
   double profit = 0;
   for(int i = 0; i < OrdersHistoryTotal(); i++)
     {
      if(!(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)))
        {
         break;
        }
      if(OrderSymbol() != "")
        {
         if(OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, day) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, day) + 86400)
           {
            profit += OrderProfit() + OrderSwap() + OrderCommission();
           }
        }
     }

   if(isCent)
     {
      return profit / 100;
     }
   return profit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProfitToday()
  {
   return ProfitForDay(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProfitYesterday()
  {
   return ProfitForDay(1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProfitWeek()
  {
   double profit = 0;
   for(int i = 0; i < DayOfWeek(); i++)
     {
      profit += ProfitForDay(i);
     }
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProfitMonth()
  {
   double profit = 0;
   for(int i = 0; i < Day(); i++)
     {
      profit += ProfitForDay(i);
     }
   return profit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Balance()
  {
   double result = AccountBalance();
   if(isCent)
     {
      return result / 100;
     }
   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Equity()
  {
   double result = AccountEquity();
   if(isCent)
     {
      return result / 100;
     }
   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FreeMargin()
  {
   double result = AccountFreeMargin();
   if(isCent)
     {
      return result / 100;
     }
   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Profit()
  {
   double result = AccountProfit();
   if(isCent)
     {
      return result / 100;
     }
   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate()
  {
   rowCounter = 0;

// Расчет просадки
   if(AccountProfit() < 0)
     {
      drawdown = (AccountProfit() * (-1) * 100) / AccountBalance();
     }
   else
     {
      drawdown = 0;
     }

// Расчет максимальной просадки
   if(drawdown > maxDrawdown)
     {
      maxDrawdown = drawdown;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Clean()
  {
   string name;
   int totalObjects  = ObjectsTotal();
   for(int i=totalObjects - 1 ;  i >= 0 ;  i--)
     {
      name = ObjectName(i);
      if(StringFind(name, label) != -1)
        {
         ObjectDelete(name);
        }
     }
  }

//+------------------------------------------------------------------+
