﻿//+------------------------------------------------------------------+
//|                                                     LongShot.mq4 |
//|                                                 Antonio Martínez |
//|                                  https://www.tradingefectivo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Antonio Martínez"
#property link      "https://www.tradingefectivo.com"
extern string   __Media_Movil_Rapida__20;
extern int      Periodo_MM20  = 20;  // MA Rápida
extern int      Metodo_MM20   = 1;  // Tipo de MA Rápida: 0-Simple, 1-Exponential, 2-Smoothed, 3-Weighted
extern int      Precio_MM20   = 0;  // Precio de MA Rápida: 0-6 PRICE_CLOSE,PRICE_OPEN,PRICE_HIGH,PRICE_LOW,PRICE_MEDIAN,PRICE_TYPICAL,PRICE_WEIGHTED
//---- Variables de la Media Móvil Lenta ----------------------------+

//---- Variables de la Media Móvil Rápida ---------------------------+
extern string   __Media_Movil_Rapida__;
extern int      Periodo_MMRapida  = 9;  // MA Rápida
extern int      Metodo_MMRapida   = 1;  // Tipo de MA Rápida: 0-Simple, 1-Exponential, 2-Smoothed, 3-Weighted
extern int      Precio_MMRapida   = 0;  // Precio de MA Rápida: 0-6 PRICE_CLOSE,PRICE_OPEN,PRICE_HIGH,PRICE_LOW,PRICE_MEDIAN,PRICE_TYPICAL,PRICE_WEIGHTED
//---- Variables de la Media Móvil Lenta ----------------------------+
extern string   __Media_Movil_Lenta__;  
extern int      Periodo_MMLenta   = 26; // MA Lenta
extern int      Metodo_MMLenta    = 1;  // Tipo de MA Lenta: 0-Simple, 1-Exponential, 2-Smoothed, 3-Weighted
extern int      Precio_MMLenta    = 0;  // Precio de MA Lenta: 0-6 PRICE_CLOSE,PRICE_OPEN,PRICE_HIGH,PRICE_LOW,PRICE_MEDIAN,PRICE_TYPICAL,PRICE_WEIGHTED
  //---- Parametros del RSI ---------------------------------------------+
extern string    _____RSI______________;
extern int      Periodo_RSI       = 14; // periodo del RSI
extern int      Precio_RSI        = 0;  // precio del RSI: 0-6 PRICE_CLOSE,PRICE_OPEN,PRICE_HIGH,PRICE_LOW,PRICE_MEDIAN,PRICE_TYPICAL,PRICE_WEIGHTED
extern int      RSI_Nivel         = 50; // Valor límite del RSI para posiciones largas
//----- Variables Globales ---------------------------------------+
static string   symbol;
static int      shift = 0;
static bool     Alerted;
static bool     Alerted_ma_20;
static datetime Tiempo;
int init()
  {
      symbol         = Symbol();
      Alerted        = false;
      Tiempo         = TimeCurrent();
      Alerted_ma_20  = false;
      //Print("init");
      return(0);
  }

int start()
  {
      //Print("start ");
       double fast_ma_0_20 = iMA(NULL, 0, Periodo_MM20, 0,  Metodo_MM20, Precio_MM20, shift);
       if ( (Alerted_ma_20 == false) && (Tiempo < (TimeCurrent() + (Period() * 1)))){
              double close= iClose(Symbol(),0,1);
                Alert("precio de la velo close ", close);
               Alert("Ma 20 ", Symbol(), fast_ma_0_20  );
             
              
             if(fast_ma_0_20 < close){
               Alerted_ma_20 = true;
               SendNotification( Symbol()+" La vela ha cerrado por encima de la  MA20: "+fast_ma_0_20+" Vela close: "+close + " periodo: "+Period() );
             }
             if(fast_ma_0_20 > close){
               Alerted_ma_20 = true;
               SendNotification( Symbol()+" La vela ha cerrado por debajo de la  MA20: "+fast_ma_0_20+" Vela close: "+close + " periodo: "+Period()  );
             }
       }
            
      if ((Alerted == false) && (Tiempo < (TimeCurrent() + (Period() * 1))))
        {
            //Print("alerted", Alerted);
            double rsi_0 = iRSI(NULL, 0, Periodo_RSI, Precio_RSI, shift);
            double rsi_1 = iRSI(NULL, 0, Periodo_RSI, Precio_RSI, shift+1);
            //---- Señal Principal --------------------------------------------+
           
            double fast_ma_1_20 = iMA(NULL, 0, Periodo_MM20, 0,  Metodo_MM20, Precio_MM20, shift+1);
            
            
            double fast_ma_0 = iMA(NULL, 0, Periodo_MMRapida, 0,  Metodo_MMRapida, Precio_MMRapida, shift);
            double fast_ma_1 = iMA(NULL, 0, Periodo_MMRapida, 0,  Metodo_MMRapida, Precio_MMRapida, shift+1);
            double slow_ma_0 = iMA(NULL, 0, Periodo_MMLenta, 12, Metodo_MMLenta, Precio_MMLenta, shift);
            double slow_ma_1 = iMA(NULL, 0, Periodo_MMLenta, 12, Metodo_MMLenta, Precio_MMLenta, shift+1);
            int trade_signal = 0;
            
            
           /* double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
            Print("Minimum Stop Level=",minstoplevel," points");
            double price=Ask;
         //--- calculated SL and TP prices must be normalized
            double stoploss=NormalizeDouble(Bid-minstoplevel*Point,Digits);
            double takeprofit=NormalizeDouble(Bid+minstoplevel*Point,Digits);
           int ticket=OrderSend(Symbol(),OP_BUY,1,price,3,stoploss,takeprofit,"My order",16384,0,clrGreen);
           if(ticket<0)
              {
               Print("OrderSend failed with error #",GetLastError());
              }
            else
               Print("OrderSend placed successfully");*/
            if(slow_ma_1 >= fast_ma_1 && slow_ma_0 < fast_ma_0) trade_signal++;
            if(slow_ma_1 <= fast_ma_1 && slow_ma_0 > fast_ma_0) trade_signal--;
            /*Print("slow_ma_1 ", slow_ma_1);
            Print("slow_ma_0 ", slow_ma_0);
            Print("fast_ma_1 ", fast_ma_1);
            Print("fast_ma_0 ", fast_ma_0);*/
            //Print("trade_signal ", trade_signal);
            if(trade_signal == 0) return(0);
         
            
            //---- Señal de Compra ------------------------------------------+
            if (rsi_0 > RSI_Nivel)
              {
                 
                  //Alert("LongShot: Comprar. ", Symbol(), " Período: ", Period(), " Precio: ", Bid, "/", Ask);
                  Alerted = true;
                  Tiempo = TimeCurrent();
                  string msg = "LongShot-Comprar-"+Symbol()+"-Periodo: "+Period()+"-Precio:-bid:"+Bid+"-ask:"+Ask;
                  //sendMessage(msg);
                  SendNotification(msg2);
                  //extern string response = cpr::Get(cpr::Url{"http://httpbin.org/get"});
                  //Print(response);
                  //Alert("LongShot: Comprar. ", Symbol(), " Período: ", Period(), " Precio: ", Bid, "/", Ask, "res ",response.text);
              }  
            //---- Señal de Venta ------------------------------------------+
            else
              {
                  if (rsi_0 < RSI_Nivel)
                        {
                          
                          //Alert("LongShot: Vender. ", Symbol(), " Período: ", Period(), " Precio: ", Bid, "/", Ask);
                          Alerted = true;
                          Tiempo = TimeCurrent();
                          string msg2 = "LongShot-Vender-"+Symbol()+"-Periodo-"+Period()+"-Precio-bid:"+Bid+"-ask:"+Ask;
                          //sendMessage(msg2);
                          SendNotification(msg2);
                        }  
              }
        }
  }  
  
 
 void sendMessage (string msg){
      /*int len = StringLen(msg);
      MT4String encodedValue;
      uchar characters[];
      StringToCharArray(value,characters);
      for (int i = 0; i<len ;i++) {
         encodedValue.append(StringFormat("%%%02x", characters[i]));
      }
      msg= encodedValue.toString();
      */
      
   /*string cookie=NULL,headers;
   char post[],result[];
   int res;
   string url="http://planetcoinbot.herokuapp.com/sendMessage/"+msg;
   ResetLastError();
   int timeout=5000;
   res=WebRequest("GET",url,cookie,NULL,timeout,post,0,result,headers);*/
   
    
      if(!SendNotification(msg))
        {
         Print("Sending message failed");
        }
      else
        {
         Print("Message sent");
        }
 }
