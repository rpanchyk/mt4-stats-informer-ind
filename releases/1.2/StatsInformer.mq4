//+------------------------------------------------------------------+
//|                                                StatsInformer.mq4 |
//|                                         Copyright 2020, GoNaMore |
//|                Based on 'stat informer2.mq4' from NeO since 2012 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, GoNaMore"
#property link      "https://github.com/gonamore/fxsi"
#property description "Indicator shows trading statistics"
#property version   "1.2"
#property strict
#property indicator_chart_window

// constants
const string label = "label_stats_informer_";
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
extern Position position = Left; //Позиция отображения
extern int indentX = 15; //Отступ сбоку
extern int indentY = 55; //Отступ сверху
extern int indentLine = 17; //Отступ между строк
extern bool isCentAccount = true; //Центовый счет?
extern bool isShowCurrencySign = true; //Показывать символ валюты счета?
extern string currencySign = "$"; //Символ валюты счета

// runtime
int rowCounter;
double drawdown;
double maxDrawdown;

//+------------------------------------------------------------------+
//| Remove all created objects                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Clean();
  }

//+------------------------------------------------------------------+
//| Расчет значений индикатора                                       |
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
   AddRow("Сегодня: " + ProfitToday() + CurrencySign());
   AddRow("Вчера: " + ProfitYesterday() + CurrencySign());
   AddRow("Неделя: " + ProfitWeek() + CurrencySign());
   AddRow("Месяц: " + ProfitMonth() + CurrencySign());
   AddRow("----------------------------------", true);
   AddRow("Баланс: " + AccountInfo(ACCOUNT_BALANCE) + CurrencySign());
   AddRow("Средства: " + AccountInfo(ACCOUNT_EQUITY) + CurrencySign());
   AddRow("Свободно: " + AccountInfo(ACCOUNT_MARGIN_FREE) + CurrencySign());
   AddRow("Прибыль: " + AccountInfo(ACCOUNT_PROFIT) + CurrencySign());
   AddRow("Просадка тек.: " + NormalizeValue(drawdown) + PercentSign());
   AddRow("Просадка макс.: " + NormalizeValue(maxDrawdown) + PercentSign());
   AddRow("----------------------------------", true);
   AddRow("Плечо: 1:" + DoubleToStr(AccountLeverage(), 0));
   AddRow("Спред: " + DoubleToStr(NormalizeDouble((Ask - Bid)/Point, 1), 1));
   AddRow("----------------------------------", true);

   return rates_total;
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
void AddRow(string value, bool isSeparator = false)
  {
   rowCounter++;
   string objectName = label + IntegerToString(rowCounter);

   if(ObjectFind(objectName) == -1)
     {
      ObjectCreate(objectName, OBJ_LABEL, 0, 0, 0);
      ObjectSet(objectName, OBJPROP_CORNER, position);
      ObjectSet(objectName, OBJPROP_XDISTANCE, indentX);

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
string CurrencySign()
  {
   if(!isShowCurrencySign)
     {
      return NULL;
     }
   return " " + currencySign;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PercentSign()
  {
   return " " + "%";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProfitForDay(int day)
  {
   double result = 0;
   for(int i = 0; i < OrdersHistoryTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         break;
        }
      if(OrderSymbol() != "" && OrderCloseTime() >= iTime(NULL, PERIOD_D1, day) && OrderCloseTime() < iTime(NULL, PERIOD_D1, day) + 86400)
        {
         result += OrderProfit() + OrderSwap() + OrderCommission();
        }
     }
   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProfitForDays(int days)
  {
   double result = 0;
   for(int i = 0; i < days; i++)
     {
      result += ProfitForDay(i);
     }
   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string NormalizeValue(double value)
  {
   double result = value;
   if(isCentAccount)
     {
      result /= 100;
     }
   return DoubleToString(result, 2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ProfitToday()
  {
   return NormalizeValue(ProfitForDay(0));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ProfitYesterday()
  {
   return NormalizeValue(ProfitForDay(1));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ProfitWeek()
  {
   return NormalizeValue(ProfitForDays(DayOfWeek()));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ProfitMonth()
  {
   return NormalizeValue(ProfitForDays(Day()));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string AccountInfo(ENUM_ACCOUNT_INFO_DOUBLE info)
  {
   return NormalizeValue(AccountInfoDouble(info));
  }
//+------------------------------------------------------------------+
