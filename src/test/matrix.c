int main()
{
   int arrayA[400]; 
   int arrayB[400];
   int arrayC[400]; 
   int MA; 
   int NA; 
   int MB; 
   int NB; 
   int MC; 
   int NC;
   int i; 
   int j; 
   int i_a;
   int i_b;
   int temp;
   MA = 0; 
   NA = 0; 
   MB = 0; 
   NB = 0; 
   MC = 0; 
   NC = 0; 
   i = 0; 
   j = 0; 
   i_a = 0;
   i_b = 0;

   scand(MA);
   scand(NA);
   while (i<MA){
      while (j<NA){
	      scand(temp);
         arrayA[i*NA+j] = temp;
         j = j + 1;
      }
      j = 0; 
      i = i + 1;
   }   

   scand(MB);
   scand(NB);
   if (NA!=MB) {
      println("Incompatible Dimensions");
      return 0;
   }

   i = 0;
   j = 0;
   while (i<MB){
      while (j<NB){
         scand(temp);
	      arrayB[i*NB+j] = temp;
         j = j + 1;
      }
      j = 0; 
      i = i + 1;
   }
      
   MC = MA;
   NC = NB;
   i = 0;
   j = 0;

   while (i<MC){
      while (j<NC){
         i_a = 0;
         i_b = j;
         while (i_a<NA){
            int x = arrayA[i*NA+i_a];
            int y = arrayB[i_b];
            temp = arrayC[i*NC+j];
            temp = temp + x*y;
            arrayC[i*NC+j] = temp;
            i_a = i_a + 1;
            i_b = i_b + NB;
         }
         j = j + 1;
      }
      j = 0;
      i = i + 1;
   }

   i = 0;
   j = 0;
   while (i<MC){
      while (j<NC){
         temp = arrayC[i*NC+j];
         printsp(10,temp);
         j = j + 1;
      }
      println("");
      j = 0; 
      i = i + 1;
   }  

   return 0;
}
