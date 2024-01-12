//+------------------------------------------------------------------+
//|                                                StatsInformer.mq4 |
//|                                         Copyright 2020, rpanchyk |
//|                Based on 'stat informer2.mq4' from NeO since 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2020, rpanchyk"
#property link        "https://github.com/rpanchyk/mt4-stats-informer-ind"
#property description "Indicator shows trading statistics"
#property version     "1.6"
#property strict
#property indicator_chart_window

// constants
const string SEPARATOR_CMD = "#SEPARATOR#"; // Команда для обозначения строки-разделителя
const string JUSTIFY_CMD = "#JUSTIFY#"; // Команда для обозначения строки с выравниваем текста по центру
string TEXT_INDENT = "  "; // Отступ слева и справа для строк
enum POSITION // Переопределяет ENUM_BASE_CORNER перечисление
  {
   Left = CORNER_LEFT_UPPER, // Слева
   Right = CORNER_RIGHT_UPPER // Справа
  };

// config
extern bool isActive = true; // Показывать на графике?
extern string fontFamily = "Tahoma"; // Шрифт
extern int fontSize = 10; // Размер шрифта
extern color fontColor = clrGainsboro; // Цвет шрифта
extern color backgroundColor = clrDarkGreen; // Цвет фона
extern color separatorColor = clrGainsboro; // Цвет разделителя
extern POSITION position = Right; // Позиция отображения
extern int indentX = 15; // Отступ сбоку
extern int indentY = 55; // Отступ сверху
extern bool isCentAccount = true; // Центовый счет?
extern bool isShowCurrencySign = true; // Показывать символ валюты счета?
extern string currencySign = "$"; // Символ валюты счета

// runtime
string objectPrefix; // Префикс для идентификатора объекта в списке графических объектов
int rowCounter; // Счетчик строк
double drawdown; // Просадка
double maxDrawdown; // Максимальная просадка
string rows[20]; // Временный массив строк с плейсхолдерами
string composedRows[20]; // Сформированый массив строк

//+------------------------------------------------------------------+
//| Очистить объекты индикатора                                      |
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
   if(!isActive)
     {
      return rates_total;
     }

   Calculate();

   rows[0] = Separator();
   rows[1] = Row("Сервер: " + AccountServer());
   rows[2] = Separator();
   rows[3] = Justify("Прибыль");
   rows[4] = Separator();
   rows[5] = Row("Сегодня: " + ProfitToday() + CurrencySign());
   rows[6] = Row("Вчера: " + ProfitYesterday() + CurrencySign());
   rows[7] = Row("Неделя: " + ProfitWeek() + CurrencySign());
   rows[8] = Row("Месяц: " + ProfitMonth() + CurrencySign());
   rows[9] = Separator();
   rows[10] = Row("Баланс: " + AccountInfo(ACCOUNT_BALANCE) + CurrencySign());
   rows[11] = Row("Средства: " + AccountInfo(ACCOUNT_EQUITY) + CurrencySign());
   rows[12] = Row("Свободно: " + AccountInfo(ACCOUNT_MARGIN_FREE) + CurrencySign());
   rows[13] = Row("Прибыль: " + AccountInfo(ACCOUNT_PROFIT) + CurrencySign());
   rows[14] = Row("Просадка тек.: " + NormalizeValueWithoutAdjustment(drawdown) + PercentSign());
   rows[15] = Row("Просадка макс.: " + NormalizeValueWithoutAdjustment(maxDrawdown) + PercentSign());
   rows[16] = Separator();
   rows[17] = Row("Плечо: 1:" + Leverage());
   rows[18] = Row("Спред: " + Spread());
   rows[19] = Separator();

   int maxRowWidth = MaxRowWidth(rows);
   ComposeRows(rows, composedRows, maxRowWidth);
   DrawRows(composedRows, maxRowWidth);

   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Clean()
  {
   string name;
   int totalObjects = ObjectsTotal();
   for(int i = totalObjects - 1; i >= 0; i--)
     {
      name = ObjectName(i);
      if(StringFind(name, objectPrefix) != -1)
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
   objectPrefix = "fxsi_ch_" + IntegerToString(ChartID());
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
string Row(string value)
  {
   return TEXT_INDENT + value + TEXT_INDENT;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Separator()
  {
   return SEPARATOR_CMD;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isSeparator(string value)
  {
   return StringFind(value, SEPARATOR_CMD) != -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Justify(string value)
  {
   return JUSTIFY_CMD + value;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isJustified(string value)
  {
   return StringFind(value, JUSTIFY_CMD) != -1;
  }

//+------------------------------------------------------------------+
//| Возвращает самую большую длину строки из массива учитывая шрифт  |
//+------------------------------------------------------------------+
int MaxRowWidth(string &arr[])
  {
   int result = 0;
   for(int i = 0; i < ArraySize(arr); i++)
     {
      string row = arr[i];
      if(isSeparator(row) || isJustified(row))
        {
         continue;
        }
      result = MathMax(result, GetRowWidth(row));
     }
   return result;
  }

//+------------------------------------------------------------------+
//| Расчет длины текста в точках при отображении на графике          |
//+------------------------------------------------------------------+
int GetRowWidth(string value)
  {
   TextSetFont(fontFamily, fontSize * -10);
   int width, height;
   TextGetSize(value, width, height);
//Print("value: ", value, " width: ", width, " height: ", height);
   return width;
  }

//+------------------------------------------------------------------+
//| Расчет высоты текста в точках при отображении на графике         |
//+------------------------------------------------------------------+
int GetRowHeight(string value)
  {
   TextSetFont(fontFamily, fontSize * -10);
   int width, height;
   TextGetSize(value, width, height);
//Print("value: ", value, " width: ", width, " height: ", height);
   return height;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ComposeRows(string &in[], string &out[], int maxRowWidth)
  {
   for(int i = 0; i < ArraySize(in); i++)
     {
      string row = in[i];
      out[i] = isJustified(row) ? CreateJustified(row, maxRowWidth) : row;
     }
  }

//+------------------------------------------------------------------+
//| Возвращает строку с выравниваем по центру                        |
//+------------------------------------------------------------------+
string CreateJustified(string value, int maxRowWidth)
  {
   string result = value;
   StringReplace(result, JUSTIFY_CMD, "");

   while(GetRowWidth(result) <= maxRowWidth)
     {
      result = " " + result + " ";
     }
   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawRows(string &arr[], int maxRowWidth)
  {
   int rowHeight = GetRowHeight("A0");
   for(int i = 0; i < ArraySize(arr); i++)
     {
      AddRow(arr[i], maxRowWidth, rowHeight);
     }
  }

//+------------------------------------------------------------------+
//| Рисует строку на графике                                         |
//+------------------------------------------------------------------+
void AddRow(string value, int maxRowWidth, int rowHeight)
  {
   rowCounter++;
   long chartId = ChartID();

   int x = indentX;
   if(position == Right)
     {
      // Adjust for OBJ_RECTANGLE_LABEL
      x = indentX + maxRowWidth;
     }
   int y = indentY + (rowHeight * (rowCounter - 1));

   string bgId = objectPrefix + "_bg_" + IntegerToString(rowCounter);
   if(ObjectFind(bgId) == -1)
     {
      if(!ObjectCreate(chartId, bgId, OBJ_RECTANGLE_LABEL, 0, 0, 0))
        {
         Print("Error creating background", GetLastError());
         return;
        }
      ObjectSet(bgId, OBJPROP_CORNER, position);
      ObjectSet(bgId, OBJPROP_XDISTANCE, x);
      ObjectSet(bgId, OBJPROP_YDISTANCE, y);
      ObjectSet(bgId, OBJPROP_XSIZE, maxRowWidth);
      ObjectSet(bgId, OBJPROP_YSIZE, rowHeight + 2);
      ObjectSet(bgId, OBJPROP_BGCOLOR, backgroundColor);
      ObjectSet(bgId, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSet(bgId, OBJPROP_COLOR, backgroundColor);
      ObjectSet(bgId, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(bgId, OBJPROP_WIDTH, 0);
      ObjectSet(bgId, OBJPROP_BACK, false);
      ObjectSet(bgId, OBJPROP_SELECTABLE, false);
      ObjectSet(bgId, OBJPROP_SELECTED, false);
      ObjectSet(bgId, OBJPROP_HIDDEN, false);
     }

   if(isSeparator(value))
     {
      string spId = objectPrefix + "_sp_" + IntegerToString(rowCounter);
      if(ObjectFind(spId) == -1)
        {
         if(!ObjectCreate(chartId, spId, OBJ_RECTANGLE_LABEL, 0, 0, 0))
           {
            Print("Error creating separator", GetLastError());
            return;
           }
         ObjectSet(spId, OBJPROP_CORNER, position);
         ObjectSet(spId, OBJPROP_XDISTANCE, x);
         ObjectSet(spId, OBJPROP_YDISTANCE, y + rowHeight / 2);
         ObjectSet(spId, OBJPROP_XSIZE, maxRowWidth);
         ObjectSet(spId, OBJPROP_YSIZE, 3);
         ObjectSet(spId, OBJPROP_BGCOLOR, separatorColor);
         ObjectSet(spId, OBJPROP_BORDER_TYPE, BORDER_FLAT);
         ObjectSet(spId, OBJPROP_COLOR, separatorColor);
         ObjectSet(spId, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSet(spId, OBJPROP_WIDTH, 0);
         ObjectSet(spId, OBJPROP_BACK, false);
         ObjectSet(spId, OBJPROP_SELECTABLE, false);
         ObjectSet(spId, OBJPROP_SELECTED, false);
         ObjectSet(spId, OBJPROP_HIDDEN, false);
        }
     }
   else
     {
      string txId = objectPrefix + "_tx_" + IntegerToString(rowCounter);
      if(ObjectFind(txId) == -1)
        {
         if(!ObjectCreate(chartId, txId, OBJ_LABEL, 0, 0, 0))
           {
            Print("Error creating text", GetLastError());
            return;
           }
         ObjectSet(txId, OBJPROP_CORNER, position);
         ObjectSet(txId, OBJPROP_XDISTANCE, indentX);
         ObjectSet(txId, OBJPROP_YDISTANCE, y);
         ObjectSet(txId, OBJPROP_BACK, false);
         ObjectSet(txId, OBJPROP_SELECTABLE, false);
         ObjectSet(txId, OBJPROP_SELECTED, false);
         ObjectSet(txId, OBJPROP_HIDDEN, false);
        }

      // Set text
      ObjectSetText(txId, value, fontSize, fontFamily, fontColor);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CurrencySign()
  {
   return isShowCurrencySign ? (" " + currencySign) : NULL;
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
string NormalizeValueWithoutAdjustment(double value)
  {
   return DoubleToString(value, 2);
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
//|                                                                  |
//+------------------------------------------------------------------+
string Leverage()
  {
   return DoubleToStr(AccountLeverage(), 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Spread()
  {
   return DoubleToStr(NormalizeDouble((Ask - Bid)/Point, 1), 1);
  }
//+------------------------------------------------------------------+
