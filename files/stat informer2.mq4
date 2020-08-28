//+------------------------------------------------------------------+
//|                                                Trade figures.mq4 |
//|                                            Copyright © 2012, NeO |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, NeO"
#property link      ""

#property indicator_chart_window

//--- input parameters
extern string     ПАРАМЕТРЫ_ТЕКСТА      =  "ПАРАМЕТРЫ ТЕКСТА"; // Init Parameters
extern string     Шрифт                 =  "Courier New";
extern color      Цвет_текста_1         =  WhiteSmoke;
extern color      Цвет_текста_2         =  Ivory;
extern int        Размер_шрифта         =  12;

double Pr_01, Pr_02;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {   
//----
//ObjectsDeleteAll();
//----
   string gs_140 = "lblfin_";
   string name_8 = gs_140 + "1";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 15);
   }
   ObjectSetText(name_8, "----------------------------------", Размер_шрифта, "Шрифт_текста", Цвет_текста_1);
   
   name_8 = gs_140 + "2";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 31);
   }
   ObjectSetText(name_8, "Сервер: " + AccountServer(), Размер_шрифта, "Шрифт_текста", Цвет_текста_2); 
   
   name_8 = gs_140 + "3";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 45);
   }
   ObjectSetText(name_8, "----------------------------------", Размер_шрифта, "Шрифт_текста", Цвет_текста_1); 
   
   name_8 = gs_140 + "4";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 61);
   }
   ObjectSetText(name_8, "+           Прибыль           +", Размер_шрифта, "Шрифт_текста", Цвет_текста_1);
   
   name_8 = gs_140 + "5";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 75);
   }
   ObjectSetText(name_8, "----------------------------------", Размер_шрифта, "Шрифт_текста", Цвет_текста_1);
   
   double ld_0 = GetProfitForDay(0);
   name_8 = gs_140 + "6";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 90);
   }
   ObjectSetText(name_8, "Сегодня: " + DoubleToStr(ld_0, 2), Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   ld_0 = GetProfitForDay(1);
   name_8 = gs_140 + "7";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 110);
   }
   ObjectSetText(name_8, "Вчера: " + DoubleToStr(ld_0, 2), Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   ld_0 = GetProfitForDay(2);
   name_8 = gs_140 + "8";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 130);
   }
   ObjectSetText(name_8, "Позавчера: " + DoubleToStr(ld_0, 2), Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   ld_0 = 0;
   for (int id_day = 0; id_day < DayOfWeek(); id_day ++)
   ld_0 = ld_0 + GetProfitForDay(id_day);
   name_8 = gs_140 + "9";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 150);
   }
   ObjectSetText(name_8, "Неделя: " + DoubleToStr(ld_0, 2), Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   ld_0 = 0;
   for (id_day = 0; id_day < Day(); id_day ++)
   ld_0 = ld_0 + GetProfitForDay(id_day);
   name_8 = gs_140 + "10";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 170);
   }
   ObjectSetText(name_8, "Месяц: " + DoubleToStr(ld_0, 2), Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   name_8 = gs_140 + "11";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 185);
   }
   ObjectSetText(name_8, "----------------------------------", Размер_шрифта, "Шрифт_текста", Цвет_текста_1);
   
   name_8 = gs_140 + "12";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 201);
   }      
   ObjectSetText(name_8, "Баланс: " + DoubleToStr(AccountBalance(), 2), Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   name_8 = gs_140 + "13";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 220);
   }      
   ObjectSetText(name_8, "Средства: " + DoubleToStr(AccountEquity(), 2), Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   name_8 = gs_140 + "14";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 240);
   }      
   ObjectSetText(name_8, "Свободно: " + DoubleToStr(AccountFreeMargin(), 2), Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   name_8 = gs_140 + "15";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 260);
   }      
   ObjectSetText(name_8, "Прибыль:   " + DoubleToStr(AccountProfit(), 2), Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   // --------------------------------------------------------------------------------------------------------------------
   // Расчет просадки
   // --------------------------------------------------------------------------------------------------------------------
   if (AccountProfit() < 0)
      {
        Pr_01 = (AccountProfit() * (-1) * 100) / AccountBalance();
      } else Pr_01 = 0;
   // --------------------------------------------------------------------------------------------------------------------   
   
   name_8 = gs_140 + "16";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 280);
   }      
   ObjectSetText(name_8, "Просадка тек.:   " + DoubleToStr(Pr_01, 2) + "%", Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   // --------------------------------------------------------------------------------------------------------------------
   // Расчет максимальной просадки
   // --------------------------------------------------------------------------------------------------------------------
   if (Pr_01 > Pr_02)
   Pr_02 = Pr_01;
   // --------------------------------------------------------------------------------------------------------------------
   
   name_8 = gs_140 + "17";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 300);
   }      
   ObjectSetText(name_8, "Просадка макс.:   " + DoubleToStr(Pr_02, 2) + "%", Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   name_8 = gs_140 + "18";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 315);
   }
   ObjectSetText(name_8, "----------------------------------", Размер_шрифта, "Шрифт_текста", Цвет_текста_1);
   
   name_8 = gs_140 + "19";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 330);
   }      
   ObjectSetText(name_8, "Плечо: 1:" + DoubleToStr(AccountLeverage(), 0), Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   double Spread = NormalizeDouble((Ask - Bid)/Point, 1);
   name_8 = gs_140 + "20";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 350);
   }      
   ObjectSetText(name_8, "Спред: " + DoubleToStr(Spread, 1), Размер_шрифта, "Шрифт_текста", Цвет_текста_2);
   
   name_8 = gs_140 + "21";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 365);
   }
   ObjectSetText(name_8, "----------------------------------", Размер_шрифта, "Шрифт_текста", Цвет_текста_1);
   
   return(0);
  }
//+------------------------------------------------------------------+

double GetProfitForDay(int ai_0) {
   double ld_ret_4 = 0;
   for (int pos_12 = 0; pos_12 < OrdersHistoryTotal(); pos_12++) {
      if (!(OrderSelect(pos_12, SELECT_BY_POS, MODE_HISTORY))) break;
      if (OrderSymbol() != "")
         if (OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, ai_0) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, ai_0) + 86400) 
            {
               ld_ret_4 += OrderProfit() + OrderSwap() + OrderCommission();
            }
   }
   return (ld_ret_4);
}
