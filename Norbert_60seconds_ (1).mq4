#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

extern int ADX_Period = 14;
extern int ADX_Price = 0;
extern double Arrows_OffsetPips = -1.0;
extern bool AlertsByClosedBars = TRUE;
extern bool PopUpAlert = TRUE;
extern bool EmailAlert = FALSE;
extern bool SoundAlert = FALSE;
extern string SoundAlert_FileName_Buy = "alert.wav";
extern string SoundAlert_FileName_Sell = "alert.wav";
double G_ibuf_124[];
double G_ibuf_128[];
int Gi_132;
bool G_bool_136;
int Gi_140;
int Gi_144;
double Gd_148;
string Gs_156;
string Gs_164;

int init() {
   double Ld_0;
   Gs_164 = Symbol();
   if (Digits == 0) Ld_0 = 1.0;
   else {
      if (Digits < 2) Ld_0 = 0.1;
      else {
         if (Digits < 4) Ld_0 = 0.01;
         else Ld_0 = 0.0001;
      }
   }
   if (StringFind(Gs_164, "XAU") >= 0) Ld_0 = 0.1;
   else
      if (StringFind(Gs_164, "XAG") >= 0) Ld_0 = 0.01;
   if (Arrows_OffsetPips < 0.0) {
      switch (Period()) {
      case PERIOD_M1:
         Arrows_OffsetPips = 2.0;
         break;
      case PERIOD_M5:
         Arrows_OffsetPips = 2.0;
         break;
      case PERIOD_M15:
         Arrows_OffsetPips = 4.0;
         break;
      case PERIOD_M30:
         Arrows_OffsetPips = 4.0;
         break;
      case PERIOD_H1:
         Arrows_OffsetPips = 10.0;
         break;
      case PERIOD_H4:
         Arrows_OffsetPips = 16.0;
         break;
      case PERIOD_D1:
         Arrows_OffsetPips = 40.0;
         break;
      case PERIOD_W1:
         Arrows_OffsetPips = 100.0;
         break;
      case PERIOD_MN1:
         Arrows_OffsetPips = 200.0;
         break;
      default:
         Arrows_OffsetPips = 10.0;
      }
   }
   Gd_148 = NormalizeDouble(Arrows_OffsetPips * Ld_0, Digits);
   if (SoundAlert)
      if (StringLen(SoundAlert_FileName_Buy) <= 0 && StringLen(SoundAlert_FileName_Sell) <= 0) SoundAlert = FALSE;
   G_bool_136 = SoundAlert || EmailAlert || PopUpAlert;
   Gs_156 = f0_0(Period());
   if (AlertsByClosedBars) Gi_132 = 1;
   else Gi_132 = 0;
   IndicatorShortName("ADX_Alerts");
   IndicatorBuffers(2);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
   SetIndexBuffer(0, G_ibuf_124);
   SetIndexBuffer(1, G_ibuf_128);
   SetIndexLabel(0, "ArrowBuy");
   SetIndexLabel(1, "ArrowSell");
   SetIndexDrawBegin(0, ADX_Period);
   SetIndexDrawBegin(1, ADX_Period);
   return (0);
}


int deinit() {
   return (0);
}

int start() {
   double iadx_12;
   double iadx_20;
   double iadx_28;
   double iadx_36;
   int Li_0 = IndicatorCounted();
   if (Li_0 < 0) return (-1);
   if (Li_0 > 0) Li_0--;
   int Li_4 = Bars - Li_0;
   for (int Li_8 = Li_4; Li_8 >= 0; Li_8--) {
      G_ibuf_124[Li_8] = EMPTY_VALUE;
      G_ibuf_128[Li_8] = EMPTY_VALUE;
      iadx_12 = iADX(NULL, 0, ADX_Period, ADX_Price, MODE_PLUSDI, Li_8);
      iadx_20 = iADX(NULL, 0, ADX_Period, ADX_Price, MODE_PLUSDI, Li_8 + 1);
      iadx_28 = iADX(NULL, 0, ADX_Period, ADX_Price, MODE_MINUSDI, Li_8);
      iadx_36 = iADX(NULL, 0, ADX_Period, ADX_Price, MODE_MINUSDI, Li_8 + 1);
      if (iadx_12 > iadx_28) {
         if (iadx_20 < iadx_36) G_ibuf_124[Li_8] = NormalizeDouble(Low[Li_8] - Gd_148, Digits);
      } else
         if (iadx_12 < iadx_28 && iadx_20 > iadx_36) G_ibuf_128[Li_8] = NormalizeDouble(High[Li_8] + Gd_148, Digits);
   }
   if (G_bool_136) {
      if (Gi_140 != Time[0]) {
         if (G_ibuf_124[Gi_132] != EMPTY_VALUE) {
            if (SoundAlert)
               if (StringLen(SoundAlert_FileName_Buy) > 0) PlaySound(SoundAlert_FileName_Buy);
            if (EmailAlert) {
               SendMail(StringConcatenate("Alert from indicator \"", "ADX_Alerts", "\": ", Gs_164, " ", Gs_156, " BUY ", TimeToStr(TimeCurrent())), StringConcatenate("ADX_Alerts",
                  ": ", Gs_164, " ", Gs_156, " BUY ", TimeToStr(TimeCurrent())));
            }
            if (PopUpAlert) Alert(StringConcatenate("ADX_Alerts", ": ", Gs_164, " ", Gs_156, " BUY ", TimeToStr(TimeCurrent())));
            Gi_140 = Time[0];
         }
      }
      if (Gi_144 != Time[0]) {
         if (G_ibuf_128[Gi_132] != EMPTY_VALUE) {
            if (SoundAlert)
               if (StringLen(SoundAlert_FileName_Sell) > 0) PlaySound(SoundAlert_FileName_Sell);
            if (EmailAlert) {
               SendMail(StringConcatenate("Alert from indicator \"", "ADX_Alerts", "\": ", Gs_164, " ", Gs_156, " SELL ", TimeToStr(TimeCurrent())), StringConcatenate("ADX_Alerts",
                  ": ", Gs_164, " ", Gs_156, " SELL ", TimeToStr(TimeCurrent())));
            }
            if (PopUpAlert) Alert(StringConcatenate("ADX_Alerts", ": ", Gs_164, " ", Gs_156, " SELL ", TimeToStr(TimeCurrent())));
            Gi_144 = Time[0];
         }
      }
   }
   return (0);
}


string f0_0(int Ai_0) {
   string str_concat_8;
   switch (Ai_0) {
   case 0:
      str_concat_8 = f0_0(Period());
      break;
   case 1:
      str_concat_8 = "M1";
      break;
   case 5:
      str_concat_8 = "M5";
      break;
   case 15:
      str_concat_8 = "M15";
      break;
   case 30:
      str_concat_8 = "M30";
      break;
   case 60:
      str_concat_8 = "H1";
      break;
   case 240:
      str_concat_8 = "H4";
      break;
   case 1440:
      str_concat_8 = "D1";
      break;
   case 10080:
      str_concat_8 = "W1";
      break;
   case 43200:
      str_concat_8 = "MN";
      break;
   default:
      str_concat_8 = StringConcatenate("M", DoubleToStr(Ai_0, 0));
   }
   return (str_concat_8);
}
