int quick_sort(int array, int left, int right)
{
    int i;
    int j;
    int x;
    int m;
    int n;
    int array1[10000];
    int array2[10000];
    if (left < right)
    {
        i = left;
        j = right;
        x = array[i];
        while (i < j)
        {
            while (i < j)
            {
                int temp1 = array[j];
                if(temp1<=x)
                {
                    break;
                }
                j = j - 1;
            }
            if (i < j)
            {
                int temp = array[j];
                array[i] = temp;
                i = i + 1;
            }
            else{}
            while (i < j)
            {
                int temp5 = array[i];
                if(temp5>=x)
                {
                    break;
                }
                i = i + 1;
            }
            if (i < j)
            {
                int temp2 = array[i];
                array[j] = temp2;
                j = j - 1;
            }
            else
            {

            }
        }
        array[i] = x;
        int temp6 = i - 1;
        int temp7 = i + 1;
        array1 = quick_sort(array, left, temp6);
        array2 = quick_sort(array1, temp7, right);
        return array2;
    }
    else
    {

    }
    return array;
}

int main()
{
    int array[10000];
    int array3[10000];
    int i;
    int N;
    int left;
    int right;
    int temp3;
    int temp4;
    scand(N);
    i = 0;
    while (i < N)
    {
        scand(temp3);
        array[i] = temp3;
        i = i + 1;
    }

    left = 0;
    right = N - 1;

    array3 = quick_sort(array, left, right);

    i = 0;
    while (i < N)
    {
        temp4 = array3[i];
        println(temp4);
        i = i + 1;
    }

    return 0;
}