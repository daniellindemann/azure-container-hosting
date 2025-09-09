public static class RandomExtensions
{
    public static double NextDouble(this Random random, double minimum, double maximum)
    {
        return NextDouble(random, minimum, maximum, 2);
    }

    public static double NextDouble(this Random random, double minimum, double maximum, int digits)
    {
        double randomDouble = random.NextDouble() * (maximum - minimum) + minimum;
        return Math.Round(randomDouble, digits);
    }
}
