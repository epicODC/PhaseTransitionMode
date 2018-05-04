/*
 

  日期:2016.8.14
 
  功能:用蒙特卡洛方法对二维数组进行概率运算
 
  目的:模拟二维Lsling模型的结果


*/




#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

//=========声明自定义函数==============================================================

  //int Ham(int cl[102][102]);
  int Mag(int cl[102][102]);
  float exc_Mag(int cl[20001]);
 
//==========主函数体===================================================================
  
  int main()
    { 
 //---------定义并初始化数组----------------------------------------------------------
      int lsing[102][102];
      int begin_a;
      float begin_b;
       
      srand((unsigned) time(NULL));        //随机数种子(时间)
     
      for (int i0 = 0; i0 < 102; i0++)
       {
         for(int j0 = 0; j0 < 102; j0++)
          {
             begin_a = rand();
             begin_b = begin_a/(float)(RAND_MAX);
              if (begin_b < 0.5)
                {
                   lsing[i0][j0] = -1;
                }           
              else
                {
                   lsing[i0][j0] = 1;
                }
          }   
       }
      
 /*  
       for (int i = 0; i < 102; i++)
         {
            for (int j = 0; j < 102; j++)
                {
                   printf("%d ", lsling[i][j]);
                }
         }   
   
  */
 //----------进入主程序体--------------------------------------------------------------
        int H_bef;                         //翻转前,指定翻转点四臂的能量和
        int sp_T = 0;                      //温度变化循环的循环子
        int change_a;       
        float change_b;                     //生成0~1随机数用到的两个变量
        float p;                            //datE大于0时,新态的接受概率
        float re_T = 1.0;                   //相对温度(1.0~3.5)   
        int pick1, pick2;                   //随机翻转点
        int M;                              //单次取样磁矩值
        int M_group[20001];                 //取样磁矩值分布
        float sum_M;                        //宏观总磁矩
        int fin_Data[2][26];                //最终数据记录表格
         
     
         
        for (re_T = 3.50; re_T >= 1.00; re_T = re_T - 0.05)
          {                                   //温度逐减(3.5~1.0, 0.1)
           
          
    //=***************初始化M_group数组为0******************************************* 
      
            for (int ima = 0; ima <20001; ima++)
              {
                 M_group[ima] = 0;
              }                          


    //=*************操作系统循环5,000,000次,使其达到平衡******************************            
            for (int i = 0; i < 5000000; i++)
              {
                  pick1 = rand()%100+1;         
                  pick2 = rand()%100+1;     //随机生成一对1~100的整数
                  
                  H_bef = -lsing[pick1][pick2] * (lsing[pick1-1][pick2] + lsing[pick1+1][pick2] 
                                                 + lsing[pick1][pick2-1] + lsing[pick1][pick2+1]);
                                             //计算取样点四臂能量值
                  if (H_bef < 0)             //翻转后与翻转前能量大小关系只与翻转前能量正负有关
                    {
                       p = exp((2*H_bef) / (re_T));
                    
                       change_a = rand();
                       change_b = change_a/(float)(RAND_MAX);//能量升高按概率取舍
 
                       //printf("%f\n", change_b);                    
                          
                          if (p > change_b)
                            {
                            lsing[pick1][pick2] = -lsing[pick1][pick2];
                            } 
                     }
                  else 
                    {
                       lsing[pick1][pick2] = -lsing[pick1][pick2];
                    }                        //能量降低,接受新值
              }



	    //=**********************开始翻转取样**************************************************            
            


             for (int i1 = 0; i1 < 500000; i1++)    //取样500,000次
              { 
                 for (int j1 = 0; j1 <1000; j1++)   //每隔1000步变化取一次样
                   {
                      for (int i2 = 1; i2<101; i2++)
                         {
                           lsing[0][i2] = lsing[100][i2];   
                           lsing[101][i2] = lsing[1][i2];
                           lsing[i2][0] = lsing[i2][100];
                           lsing[i2][101] = lsing[i2][1];//!!!!!error
                         }                     //循环边界赋值                   
 
                     pick1 = rand()%100+1;         
                     pick2 = rand()%100+1;     //随机生成一对1~100的整数
                  
                     H_bef = -lsing[pick1][pick2] * (lsing[pick1-1][pick2] + lsing[pick1+1][pick2] 
                                                 + lsing[pick1][pick2-1] + lsing[pick1][pick2+1]);
                                               //计算取样点四臂能量值
                     if (H_bef < 0)            //翻转后与翻转前能量大小关系只与翻转前能量正负有关
                       {
                         p = exp((2*H_bef) / (re_T));
                       
                          change_a = rand();
                          change_b = change_a/(float)(RAND_MAX);//能量升高按概率取舍
                          if (p > change_b)
                            {
                            lsing[pick1][pick2] = -lsing[pick1][pick2];
                            } 
                        }
                     else 
                        {
                        lsing[pick1][pick2] = -lsing[pick1][pick2];
                        }                        //能量降低,接受新值
                 
                   }
              
                 M = Mag(lsing);               //计算取样磁矩
		 M_group[M + 10000]++;                 //记录本次取样磁矩
                
              }      

//=*********************记录数据******************************************************

//            for (int i = 0; i <20001; i++)
//              {
//                printf("%d", M_group[i]);
//              }    
           
           sum_M = exc_Mag(M_group);            //计算概率统计总磁矩
          
           
           printf ("%f %d\n", re_T, abs(sum_M));
         }                                          
  
  return 0;
  }

 
//===========定义 自定义函数体=================================================================
  
  /*
    //------定义Hamilton量计算函数----------------------------------------------------
       int Ham(int cl[102][102])  
       {
          int i, j;
          int Hi, H;          
          
          Hi = 0;
          H = 0; 
          
          for (i = 1; i < 101; i++)
            {
               for (j = 1; j < 101; j++)
               {
               Hi = cl[i][j] * (cl[i-1][j] + cl[i+1][j] + cl[i][j-1] + cl[i][j+1]);
               H += Hi;       
               }

            } 
            H /= 2  
       return H;
       }
  */
 //---------定义磁矩计算函数----------------------------------------------------------
       int Mag(int cl[102][102])
          {
            int i, j;
            int Mi, M;

            M = 0;
            Mi = 0;
     
            for (i = 1; i < 101; i++)
                {
                 for (j = 1; j < 101; j++)
                     {
                      M += cl[i][j];  //讲所有单元中的磁矩加和
                     }

                 }
   
           return M;
           }  

 //----------定义磁矩期望统计计算函数------------------------------------------------
       float exc_Mag(int cl[20001])
            {
             int i;
             float exc_m;
              
               exc_m = 0;
              
               for (i = 0; i < 20001; i++)
                 {
                  exc_m += cl[i] * (i - 10000);// 计算磁矩期望                       
                 }
              
                exc_m /= 500000.00; 
               return exc_m;
            }



/*



*/
