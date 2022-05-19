int main()
{
    int array[10000];
    int N = 0;
    int i = 0;
    int j = 0;
    scand(N);
    for (i = 0; i < N; i = i + 1)
    {
        int temp = 0;
        scand(temp);
        array[i] = temp;
    }
    for (i = 1; i < N; i = i + 1)
    {
        for (j = 0; j < N - i; j = j + 1)
        {
            int temp2 = array[j];
            int temp3 = array[j + 1];
            if (temp2 > temp3)
            {
                array[j] = temp3;
                array[j + 1] = temp2;
            }
        }
    }
    for (i = 0; i < N; i = i + 1)
    {
        int temp4 = array[i];
        println(temp4);
    }
    return 0;
}