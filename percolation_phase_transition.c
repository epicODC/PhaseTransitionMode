#include<stdio.h>
#include<stdlib.h>
#include<time.h>

#define SEE_SIZE 100 //the size of observed object(2D)(SEE_SIZE*SEE_SIZE) 
#define NUM_CIR 1000000 //the number of samples

 int try_Walk(int gr[SEE_SIZE][SEE_SIZE]); 
 int step_Walk(int gr[SEE_SIZE][SEE_SIZE], int pos_x, int pos_y);
       
//=======================================================================
//*******************************main funcion****************************
//=======================================================================

 int main(void)
  {
    int Gr_see[SEE_SIZE][SEE_SIZE]; 
    float pro_distr; //probabililty of distribution 
    float dens_distr; //the changing rate of pro_distr  
    float rand_jud; 
    int get_num;   
    float pro_get;  //probability of finding a way

    //printf("Plaese input the changing rate of the probability in distribution(<1):");
    //scanf("%f", &dens_distr); 
    
    dens_distr = 0.001;
    printf("\n\npro_dis           pro_get\n");
    printf("--------------------------------\n");   

    srand((unsigned)time(NULL)); // A seed for random number
     
    pro_distr = 0.645000;    
    while(pro_distr<=0.700000)  //**#first circle#**//
     {
       get_num = 0;
     
       for(int stat_cir=0; stat_cir<NUM_CIR; stat_cir++) //**#second circle#**//
         {

           //-----------initialize the group------------
           for(int init_x=0; init_x<SEE_SIZE; init_x++)    
            {
              for(int init_y=0; init_y<SEE_SIZE; init_y++)
                {
                  rand_jud = rand()/(float)(RAND_MAX);
                
                  if(rand_jud<pro_distr)
                     Gr_see[init_x][init_y] = 1; 
                  else
                     Gr_see[init_x][init_y] = 0;
                }
            } 
           //--------------end------------------------
      
           get_num += try_Walk(Gr_see); 

         }
         
        pro_get = get_num / (float)(NUM_CIR); //calculate the probability of finding a way
        
        printf("%f          %f\n", pro_distr, pro_get);
    
        pro_distr += dens_distr;  // change the probability of distribution  
      }
    return 0;
  }

//==============================================================================
//************************function define***************************************
//============================================================================== 
  
 int try_Walk(int gr[SEE_SIZE][SEE_SIZE])
  {
    int res_try = 0;

    for(int beg_pos=0; beg_pos<SEE_SIZE; beg_pos++)   //locate the start point
        if(gr[0][beg_pos] && step_Walk(gr, 0, beg_pos)) //if... 
          {
            res_try = 1;
            break;       //find a way!
          }
         
    return res_try;
  }



 int step_Walk(int gr[SEE_SIZE][SEE_SIZE], int pos_x, int pos_y)
  {  
    int res_step = 0; 
    int res_step_right = 0, res_step_down = 0, res_step_up = 0;

    gr[pos_x][pos_y] = -1; // no way back
     
    if(pos_x==SEE_SIZE-1) 
      res_step = 1;   //reach the destination
    else
      {
        if(gr[pos_x+1][pos_y]==1)
          res_step_right = step_Walk(gr, pos_x+1, pos_y);
        if(gr[pos_x][pos_y+1]==1)        
          res_step_down = step_Walk(gr, pos_x, pos_y+1);
        if(gr[pos_x][pos_y-1]==1)
          res_step_up = step_Walk(gr, pos_x, pos_y-1);
      }                   //A TREE for RECURION 
     
    if(res_step_right || res_step_down || res_step_up)
      res_step = 1;    //have a way(1) or not(0)

    return res_step;
  }


